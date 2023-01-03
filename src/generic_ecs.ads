with Internal.Generic_Component;
with Internal.Generic_Registery;
with Internal.Generic_Selection;

generic
   type Component_Kind_Type is (<>);
package Generic_ECS is

   package Component is new Internal.Generic_Component (Component_Kind_Type => Component_Kind_Type);
   package Selection is new Internal.Generic_Selection (Component_Package => Component);
   package Registery is new Internal.Generic_Registery (Selection_Package => Selection);

end Generic_ECS;
