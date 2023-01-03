with Ada.Containers;
with Ada.Containers.Hashed_Maps;
with Internal.Generic_Selection;

generic
   with package Selection_Package is new Internal.Generic_Selection (<>);
package Internal.Generic_Registery with
  Preelaborate
is

   package Component_Package renames Selection_Package.Component_Package;

   --------------------------
   -- Registery management --
   --------------------------

   type Registery_Type is tagged limited private;

   -- Initialize and return a new registery
   function Initialize return Registery_Type;

   -- Remove all the entities from the registery
   procedure Clear (Registery : in out Registery_Type);

   -- Return the number of entities in use
   function Count
     (Registery : Registery_Type)
      return Natural;

   -----------------------
   -- Entity management --
   -----------------------
   type Entity_Type is private;

   -- Create an entity in the register
   -- Return the created entity
   function Create
     (Registery : in out Registery_Type)
      return Entity_Type;

   -- Destroy the entity
   -- Do nothing if the entity was already destroyed or doesn't exist
   procedure Destroy
     (Registery : in out Registery_Type;
      Entity    :        Entity_Type);

   -- Return whether or not the registery has the entity
   function Has
     (Registery : Registery_Type;
      Entity    : Entity_Type)
      return Boolean;

   --------------------------
   -- Component management --
   --------------------------

   -- Assign the component to the entity in the registery
   procedure Set
     (Registery : in out Registery_Type;
      Entity    :        Entity_Type;
      Kind      :        Component_Package.Component_Kind_Type;
      Component :        Component_Package.Component_Interface_Class_Access_Type);

   -- Assign the component to the entity in the registery
   -- Return an access to the component
   function Set
     (Registery : in out Registery_Type;
      Entity    :        Entity_Type;
      Kind      :        Component_Package.Component_Kind_Type;
      Component :        Component_Package.Component_Interface_Class_Access_Type)
      return Component_Package.Component_Interface_Class_Access_Type;

   -- Remove the component designated by kind from the entity
   procedure Unset
     (Registery : in out Registery_Type;
      Entity    :        Entity_Type;
      Component :        Component_Package.Component_Kind_Type);

   -- Remove the components from the entity
   -- If selection is set to exclusive, it unsets the components only if the entity
   -- has all the selected components
   procedure Unset
     (Registery  : in out Registery_Type;
      Entity     :        Entity_Type;
      Components :        Selection_Package.Selection_Type);

   -- Unset the selected components from all entities
   -- If selection is set to exclusive, it unsets the components for the entities
   -- that have all the selected components
   procedure Unset
     (Registery  : in out Registery_Type;
      Components :        Selection_Package.Selection_Type);

   -- Check if the entity has component kind
   function Has
     (Registery : Registery_Type;
      Entity    : Entity_Type;
      Component : Component_Package.Component_Kind_Type)
      return Boolean;

   -- Check if the entity has the specified selection
   function Has
     (Registery  : Registery_Type;
      Entity     : Entity_Type;
      Components : Selection_Package.Selection_Type)
      return Boolean;

   -- Return an access to the component specified by kind from the entity
   function Get
     (Registery : Registery_Type;
      Entity    : Entity_Type;
      Component : Component_Package.Component_Kind_Type)
      return Component_Package.Component_Interface_Class_Access_Type;

   -- Return an array with each component set to true if it is set for the entity
   function Get_Set_Components
     (Registery : Registery_Type;
      Entity    : Entity_Type)
      return Component_Package.Component_Boolean_Array_Type;

   type System_Type is access procedure
       (Registery : Registery_Type;
        Entity    : Entity_Type);

   ------------
   -- System --
   ------------

   -- Run the system on each entity according to the component selection
   procedure Each
     (Registery  : in out Registery_Type;
      Components :        Selection_Package.Selection_Type;
      System     :        System_Type);

   -- Run the system on each entity
   procedure Each
     (Registery : in out Registery_Type;
      System    :        System_Type);

private

   -- An entity is just an unique id
   type Entity_Type is new Positive;

   -- Return a hash from the entity
   function Hash_Entity
     (Entity : Entity_Type)
      return Ada.Containers.Hash_Type;

   -- Associate each component kind to an access to Component_Interface'Class
   type Component_Access_Array_Type is
     array (Component_Package.Component_Kind_Type) of Component_Package.Component_Interface_Class_Access_Type;

   package Entity_Component_Hashed_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => Entity_Type,
      Element_Type    => Component_Access_Array_Type,
      Hash            => Hash_Entity,
      Equivalent_Keys => "=",
      "="             => "=");

   type Registery_Type is tagged limited record
      Last_Entity : Entity_Type;
      Entities    : Entity_Component_Hashed_Maps.Map;
   end record;

end Internal.Generic_Registery;
