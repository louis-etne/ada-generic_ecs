with AUnit.Assertions;

with Components;
with Components.Position;
with ECS;

package body Generic_ECS_Tests is

   procedure Test_Create_Entity (T : in out Test) is
      Registery : ECS.Registery_Type       := ECS.Initialize;
      Entity    : constant ECS.Entity_Type := Registery.Create;
   begin
      AUnit.Assertions.Assert (Registery.Count = 1, "wrong entity count");
   end Test_Create_Entity;

   procedure Test_Clear_Registery (T : in out Test) is
      Registery : ECS.Registery_Type       := ECS.Initialize;
      Unused    : constant ECS.Entity_Type := Registery.Create;
   begin
      AUnit.Assertions.Assert (Registery.Count = 1, "wrong entity count before clear");
      Registery.Clear;
      AUnit.Assertions.Assert (Registery.Count = 0, "wrong entity count after clear");
   end Test_Clear_Registery;

   procedure Test_Entity_Component (T : in out Test) is
      Registery : ECS.Registery_Type                                := ECS.Initialize;
      Entity    : constant ECS.Entity_Type                          := Registery.Create;
      Position : constant Components.Position.Position_Component_Access_Type := new Components.Position.Position_Component_Type;
   begin
      Position.X := 5.0;
      Position.Y := 5.0;
      Position.Z := 5.0;

      Registery.Set
        (Entity    => Entity,
         Kind      => Components.Position_Kind,
         Component => ECS.Component_Interface_Class_Access_Type (Position));

      -- Test components presence
      declare
         Set : constant ECS.Component_Boolean_Array_Type := Registery.Get_Set_Components (Entity);
      begin
         AUnit.Assertions.Assert (Set (Components.Position_Kind), "position is not set");
         AUnit.Assertions.Assert (not Set (Components.Rotation_Kind), "rotation is set");
      end;

      -- Test to retrieve a component
      declare
         use type Components.Position.Position_Component_Access_Type;

         New_Position : constant Components.Position.Position_Component_Access_Type :=
           Components.Position.Position_Component_Access_Type (Registery.Get (Entity, Components.Position_Kind));
      begin
         AUnit.Assertions.Assert (New_Position /= null, "New_Position is null");

         AUnit.Assertions.Assert (New_Position.X = 5.0, "New_Position.X /= 5.0");
         AUnit.Assertions.Assert (New_Position.Y = 5.0, "New_Position.Y /= 5.0");
         AUnit.Assertions.Assert (New_Position.Z = 5.0, "New_Position.Z /= 5.0");
      end;

      -- Test to update a component
      Position.X := 7.0;
      declare
         use type Components.Position.Position_Component_Access_Type;

         New_Position : constant Components.Position.Position_Component_Access_Type :=
           Components.Position.Position_Component_Access_Type (Registery.Get (Entity, Components.Position_Kind));
      begin
         AUnit.Assertions.Assert (New_Position.X = 7.0, "New_Position.X /= 7.0");
      end;

      -- Test to delete a component
      Registery.Unset (Entity, Components.Position_Kind);
      declare
         Set : constant ECS.Component.Component_Boolean_Array_Type := Registery.Get_Set_Components (Entity);
      begin
         AUnit.Assertions.Assert (not Set (Components.Position_Kind), "position is still set");
      end;

   end Test_Entity_Component;

end Generic_ECS_Tests;
