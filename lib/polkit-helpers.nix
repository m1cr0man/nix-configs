with builtins;
let
  DEFAULT_VERBS = ["start" "stop" "restart" "reload"];
in {
  makeUnitRule = { group, unit, verbs ? DEFAULT_VERBS }: let
  in ''
    polkit.addRule(function(action, subject) {
      // polkit.log("action = " + action);
      const group = ${toJSON group};
      const unit = ${toJSON unit};
      const verbs = ${toJSON verbs};
      if (action.lookup("unit") === unit) {
        if (
          (verbs.indexOf(action.lookup("verb")) + 1)
          && subject.isInGroup(group)
        ) {
          return polkit.Result.YES;
        }
        polkit.log("User " + subject.user + " is attempting " + action.lookup("verb") + " on unit " + unit);
        return polkit.Result.NO;
      }
    });
  '';
}
