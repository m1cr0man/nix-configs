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
      if (
        action.lookup("unit") === unit
        && (verbs.indexOf(action.lookup("verb")) + 1)
        && subject.isInGroup(group)
      ) {
        return polkit.Result.YES;
      }
      return polkit.Result.NO;
    });
  '';
}
