with AUnit.Reporter.Text;
with AUnit.Run;

with Generic_ECS_Suite;

procedure Test_Generic_ECS is
   procedure Runner is new AUnit.Run.Test_Runner (Generic_ECS_Suite.Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   Runner (Reporter);
end Test_Generic_ECS;
