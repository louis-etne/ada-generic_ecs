package body Internal.Generic_Selection is

   function Select_None
     (Selection_Kind : Selection_Kind_Type := Inclusive_Or_None)
      return Selection_Type
   is
   begin
      return (Kind => Selection_Kind, Components => (others => False));
   end Select_None;

   function Select_All
     (Selection_Kind : Selection_Kind_Type := Inclusive_Or_None)
      return Selection_Type
   is
   begin
      return (Kind => Selection_Kind, Components => (others => True));
   end Select_All;

   function Selection_Kind
     (Selection : Selection_Type)
      return Selection_Kind_Type
   is
   begin
      return Selection.Kind;
   end Selection_Kind;

   procedure Selection_Kind
     (Selection : out Selection_Type;
      Kind      :     Selection_Kind_Type)
   is
   begin
      Selection.Kind := Kind;
   end Selection_Kind;

   procedure Select_Component
     (Selection : out Selection_Type;
      Component :     Component_Package.Component_Kind_Type)
   is
   begin
      Selection.Components (Component) := True;
   end Select_Component;

   procedure Unselect_Component
     (Selection : out Selection_Type;
      Component :     Component_Package.Component_Kind_Type)
   is
   begin
      Selection.Components (Component) := False;
   end Unselect_Component;

   function Is_Selected
     (Selection : Selection_Type;
      Component : Component_Package.Component_Kind_Type)
      return Boolean
   is
   begin
      return Selection.Components (Component);
   end Is_Selected;

   function "+"
     (Component : Component_Package.Component_Kind_Type)
      return Selection_Type
   is
      Selection : Selection_Type := Select_None;
   begin
      Selection.Select_Component (Component);
      return Selection;
   end "+";

   function "+"
     (LHS, RHS : Component_Package.Component_Kind_Type)
      return Selection_Type
   is
   begin
      return (+LHS) + RHS;
   end "+";

   function "+"
     (Selection : Selection_Type;
      Component : Component_Package.Component_Kind_Type)
      return Selection_Type
   is
      Result : Selection_Type := Selection;
   begin
      Result.Select_Component (Component);
      return Result;
   end "+";

   function "="
     (Selection        : Selection_Type;
      Components_Array : Component_Package.Component_Boolean_Array_Type)
      return Boolean
   is
   begin
      case Selection.Selection_Kind is
         when Inclusive_Or_None =>
            return True;

         when Inclusive =>
            for Kind in Component_Package.Component_Kind_Type loop
               if Selection.Is_Selected (Kind) = Components_Array (Kind) then
                  return True;
               end if;
            end loop;

            return False;

         when Exclusive =>
            for Kind in Component_Package.Component_Kind_Type loop
               if Selection.Is_Selected (Kind) /= Components_Array (Kind) then
                  return False;
               end if;
            end loop;

            return True;
      end case;
   end "=";

end Internal.Generic_Selection;
