with AUnit.Test_Caller;

with Generic_ECS_Test;

package body Generic_ECS_Suite is

   package Runner is new AUnit.Test_Caller (Generic_ECS_Test.Test);

   Result : aliased AUnit.Test_Suites.Test_Suite;

   Test_Create_Entity : aliased Runner.Test_Case;
   Test_Clear_Registery : aliased Runner.Test_Case;
   Test_Entity_Component : aliased Runner.Test_Case;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
   begin
      Runner.Create
        (TC   => Test_Create_Entity,
         Name => "Create an entity",
         Test => Generic_ECS_Test.Test_Create_Entity'Access);
      Result.Add_Test (Test_Create_Entity'Access);

      Runner.Create
        (TC   => Test_Clear_Registery,
         Name => "Clear the registery",
         Test => Generic_ECS_Test.Test_Clear_Registery'Access);
      Result.Add_Test (Test_Clear_Registery'Access);

      Runner.Create
        (TC   => Test_Entity_Component,
         Name => "Test the entity component relation (set and get)",
         Test => Generic_ECS_Test.Test_Entity_Component'Access);
      Result.Add_Test (Test_Entity_Component'Access);

      return Result'Access;
   end Suite;

end Generic_ECS_Suite;
