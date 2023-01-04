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
      Registery : ECS.Registery_Type                                          := ECS.Initialize;
      Entity    : constant ECS.Entity_Type                                    := Registery.Create;
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

   procedure Test_Selection (T : in out Test) is
   begin

      -- Test basic actions
      declare
         Selection : ECS.Selection.Selection_Type;
      begin
         Selection.Select_Component (Components.Position_Kind);
         AUnit.Assertions.Assert (Selection.Is_Selected (Components.Position_Kind), "position is not selected");
         AUnit.Assertions.Assert (not Selection.Is_Selected (Components.Rotation_Kind), "rotation is selected");

         Selection.Unselect_Component (Components.Position_Kind);
         AUnit.Assertions.Assert (not Selection.Is_Selected (Components.Position_Kind), "position is still selected");
      end;

      -- Test initialization from operators
      declare
         use ECS.Selection;

         Selection : ECS.Selection.Selection_Type := +Components.Position_Kind;
      begin
         AUnit.Assertions.Assert (Selection.Is_Selected (Components.Position_Kind), "position is not selected");
         Selection := Selection + Components.Rotation_Kind;
         AUnit.Assertions.Assert (Selection.Is_Selected (Components.Rotation_Kind), "rotation is not selected");
      end;

      -- Test exclusive selection
      declare
         use ECS.Selection;

         Selection : ECS.Selection.Selection_Type     := +Components.Position_Kind;
         Match     : ECS.Component_Boolean_Array_Type := (Components.Position_Kind => True, Components.Rotation_Kind => False);
         Not_Match : ECS.Component_Boolean_Array_Type := (Components.Position_Kind => True, Components.Rotation_Kind => True);
      begin
         Selection.Selection_Kind (ECS.Selection.Exclusive);
         AUnit.Assertions.Assert (Selection = Match, "exclusive selection is not matching");
         AUnit.Assertions.Assert (Selection /= Not_Match, "exclusive selection is matching when it shouldn't");
      end;

      -- Test inclusive selection
      declare
         use ECS.Selection;

         Selection : ECS.Selection.Selection_Type     := +Components.Position_Kind;
         Match     : ECS.Component_Boolean_Array_Type := (Components.Position_Kind => True, Components.Rotation_Kind => True);
         Not_Match : ECS.Component_Boolean_Array_Type := (Components.Position_Kind => False, Components.Rotation_Kind => True);
      begin
         AUnit.Assertions.Assert (Selection = Match, "inclusive selection is not matching");
         AUnit.Assertions.Assert (Selection /= Not_Match, "inclusive selection is matching when it shouldn't");
         Not_Match := (others => False);
         AUnit.Assertions.Assert (Selection /= Not_Match, "inclusive selection is matching none");
      end;

   end Test_Selection;

   procedure Test_System_Type (T : in out Test) is
      use ECS.Selection;

      type System_Type is new ECS.Registery.System_Interface_Type with record
         Foo : Natural;
      end record;

      procedure Run
        (System   : in out System_Type;
         Register :        ECS.Registery.Registery_Access_Type;
         Entity   :        ECS.Entity_Type)
      is
      begin
         System.Foo := System.Foo + 5;
      end Run;

      Registery : ECS.Registery_Type                                          := ECS.Initialize;
      Entity    : constant ECS.Entity_Type                                    := Registery.Create;
      Position  : constant Components.Position.Position_Component_Access_Type := new Components.Position.Position_Component_Type;
      System    : System_Type                                                 := (Foo => 0);
   begin
      Registery.Set
        (Entity    => Entity,
         Kind      => Components.Position_Kind,
         Component => ECS.Component_Interface_Class_Access_Type (Position));

      Registery.Each
        (Components => +Components.Position_Kind,
         System     => System);

      AUnit.Assertions.Assert (System.Foo = 5, "System.Foo has the wrong value after running the system");

      Registery.Each
        (Components => +Components.Rotation_Kind, -- The system shouldn't run as the entity doesn't implement the rotation
         System     => System);

      AUnit.Assertions.Assert (System.Foo = 5, "System.Foo has the wrong value after running the system");

   end Test_System_Type;

end Generic_ECS_Tests;