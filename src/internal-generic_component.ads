generic
   type Component_Kind_Type is (<>);
package Internal.Generic_Component with
  Preelaborate, Pure
is

   type Component_Interface_Type is interface;
   type Component_Interface_Class_Access_Type is access all Component_Interface_Type'Class;

   type Component_Boolean_Array_Type is array (Component_Kind_Type) of Boolean with
     Pack;

end Internal.Generic_Component;
