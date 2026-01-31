#!/usr/bin/env python3
import os
from pathlib import Path

from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy import create_engine, Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Configuration via Environment Variables
DB_NAME = os.getenv("WEDDING_DB_NAME", "wedding")
DB_USER = os.getenv("WEDDING_DB_USER", "wedding")
DB_PASSWORD = os.getenv("WEDDING_DB_PASSWORD")
SOCKET_PATH = os.getenv("WEDDING_DB_SOCKET", "/var/lib/sockets")
# Construct the socket-based URL
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@/{DB_NAME}?host={SOCKET_PATH}"

# App Settings
LISTEN_ADDR = os.getenv("WEDDING_APP_HOST", "127.0.0.1")
LISTEN_PORT = int(os.getenv("WEDDING_APP_PORT", "8000"))
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class Guest(Base):
    __tablename__ = "rsvp"
    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    attending = Column(String(50), default="Yes")
    dietary = Column(Text)
    table = Column(String(255))
    partner_id = Column(Integer)
    submitted_at = Column(DateTime(timezone=True), server_default=func.now())

app = FastAPI()
templates = Jinja2Templates(directory=Path(__file__).parent / "templates")

@app.get("/", response_class=HTMLResponse)
async def index(request: Request):
    db = SessionLocal()
    all_guests = db.query(Guest).order_by(Guest.last_name).all()

    # Create a lookup map: {guest_id: table_name}
    table_map = {g.id: g.table for g in all_guests}

    # Filter for the planning view
    attending_guests = [g for g in all_guests if g.attending and g.attending.lower() == "yes"]
    unseated = [g for g in attending_guests if not g.table]

    tables = {}
    for g in attending_guests:
        if g.table:
            tables.setdefault(g.table, []).append(g)

    # Summary logic (as before)
    summary = {"Yes": 0, "No": 0, "Maybe": 0, "Total": len(all_guests)}
    for g in all_guests:
        status = (g.attending if g.attending else "Maybe").capitalize()
        if status in summary: summary[status] += 1

    db.close()
    return templates.TemplateResponse("index.html", {
        "request": request,
        "unseated": unseated,
        "tables": tables,
        "all_guests": all_guests,
        "summary": summary,
        "table_map": table_map  # Pass the lookup map to the template
    })

@app.post("/update-guest")
async def update_guest(
    guest_id: int = Form(...),
    table_name: str = Form(None),
    partner_id: str = Form(None) # Handled as string to catch "0" or empty
):
    db = SessionLocal()
    guest = db.query(Guest).filter(Guest.id == guest_id).first()
    if guest:
        # If the table input is empty string, set to None (NULL)
        guest.table = table_name.strip() if table_name and table_name.strip() else None

        # Partner ID handling
        if partner_id and partner_id != "0":
            guest.partner_id = int(partner_id)
        else:
            guest.partner_id = None

        db.commit()
    db.close()
    return RedirectResponse(url="/", status_code=303)

@app.post("/add-guest")
async def add_guest(
    first_name: str = Form(...),
    last_name: str = Form(...),
    dietary: str = Form(None)
):
    db = SessionLocal()
    new_guest = Guest(first_name=first_name, last_name=last_name, dietary=dietary)
    db.add(new_guest)
    db.commit()
    db.close()
    return RedirectResponse(url="/", status_code=303)

@app.post("/delete-guest")
async def delete_guest(guest_id: int = Form(...)):
    db = SessionLocal()
    guest = db.query(Guest).filter(Guest.id == guest_id).first()
    if guest:
        db.delete(guest)
        db.commit()
    db.close()
    return RedirectResponse(url="/", status_code=303)

@app.post("/save-all")
async def save_all(request: Request):
    db = SessionLocal()
    form_data = await request.form()

    # Identify unique guest IDs from the form inputs
    guest_ids = {fp for k in form_data.keys() if "_" in k and (fp := k.split('_')[1]).isdigit()}

    for g_id in guest_ids:
        guest = db.query(Guest).filter(Guest.id == int(g_id)).first()
        if guest:
            # Update all columns from form data
            if (val := form_data.get(f"fname_{g_id}")) and guest.first_name != val:
                guest.first_name = val
            if (val := form_data.get(f"lname_{g_id}")) and guest.last_name != val:
                guest.last_name = val
            if (val := form_data.get(f"attending_{g_id}")) and guest.attending != val:
                guest.attending = val
            if (val := form_data.get(f"dietary_{g_id}")) and guest.dietary != val:
                guest.dietary = val

            # Seating logic
            if (val := form_data.get(f"table_{g_id}")) and guest.table != val:
                guest.table = val

            if (val := form_data.get(f"partner_{g_id}")) and val != "0" and guest.partner_id != val:
                guest.partner_id = int(val)

    db.commit()
    db.close()
    return RedirectResponse(url="/", status_code=303)

def run_app():
    import uvicorn
    """Entry point for the pyproject.toml script"""
    uvicorn.run(
        "rsvp_manager.main:app",
        host=LISTEN_ADDR,
        port=LISTEN_PORT,
        reload=True
    )

if __name__ == "__main__":
    run_app()
