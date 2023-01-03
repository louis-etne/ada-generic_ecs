with AUnit.Test_Fixtures;

package Generic_ECS_Tests is

   type Test is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Test_Create_Entity (T : in out Test);
   procedure Test_Clear_Registery (T : in out Test);
   procedure Test_Entity_Component (T : in out Test);

end Generic_ECS_Tests;
