{
  lib,
  python313Packages,
}:
python313Packages.buildPythonApplication {
  pname = "rsvp-manager";
  version = "1.0.0";
  src = ./.;

  doCheck = false;
  pyproject = true;
  build-system = [
    python313Packages.setuptools
    python313Packages.wheel
  ];

  dependencies = with python313Packages; [
    fastapi uvicorn sqlalchemy jinja2
    python-multipart psycopg2-binary
  ];

  meta = {
    description = "Wedding RSVP manager";
    maintainers = [ lib.maintainers.m1cr0man ];
  };
}
