package body Internal.Generic_Registery is

   --------------------------
   -- Registery management --
   --------------------------

   function Initialize return Registery_Type is
   begin
      return Registery : Registery_Type do
         Registery.Last_Entity := Entity_Type'First;
         Registery.Entities    := Entity_Component_Hashed_Maps.Empty_Map;
      end return;
   end Initialize;

   procedure Clear (Registery : in out Registery_Type) is
   begin
      Registery.Entities.Clear;
   end Clear;

   function Count
     (Registery : Registery_Type)
      return Natural
   is
   begin
      return Natural (Registery.Entities.Length);
   end Count;

   -----------------------
   -- Entity management --
   -----------------------

   function Create
     (Registery : in out Registery_Type)
      return Entity_Type
   is
      Entity : constant Entity_Type := Registery.Last_Entity;
   begin
      Registery.Entities.Include (Entity, (others => null));
      Registery.Last_Entity := Entity_Type'Succ (Registery.Last_Entity);

      return Entity;
   end Create;

   procedure Destroy
     (Registery : in out Registery_Type;
      Entity    :        Entity_Type)
   is
   begin
      Registery.Entities.Delete (Entity);
   end Destroy;

   function Has
     (Registery : Registery_Type;
      Entity    : Entity_Type)
      return Boolean
   is
   begin
      return Registery.Entities.Contains (Entity);
   end Has;

   --------------------------
   -- Component management --
   --------------------------

   procedure Set
     (Registery : in out Registery_Type;
      Entity    :        Entity_Type;
      Kind      :        Component_Package.Component_Kind_Type;
      Component :        Component_Package.Component_Interface_Class_Access_Type)
   is
   begin
      if not Registery.Has (Entity) then
         return;
      end if;

      Registery.Entities (Entity) (Kind) := Component;
   end Set;

   function Set
     (Registery : in out Registery_Type;
      Entity    :        Entity_Type;
      Kind      :        Component_Package.Component_Kind_Type;
      Component :        Component_Package.Component_Interface_Class_Access_Type)
      return Component_Package.Component_Interface_Class_Access_Type
   is
   begin
      Registery.Set
        (Entity    => Entity,
         Kind      => Kind,
         Component => Component);

      return Registery.Get
          (Entity    => Entity,
           Component => Kind);
   end Set;

   procedure Unset
     (Registery : in out Registery_Type;
      Entity    :        Entity_Type;
      Component :        Component_Package.Component_Kind_Type)
   is
   begin
      if not Registery.Has (Entity) then
         return;
      end if;

      Registery.Entities (Entity) (Component) := null;
   end Unset;

   procedure Unset
     (Registery  : in out Registery_Type;
      Entity     :        Entity_Type;
      Components :        Selection_Package.Selection_Type)
   is
      procedure Unset_Components is
      begin
         for Kind in Component_Package.Component_Kind_Type loop
            if Components.Is_Selected (Kind) then
               Registery.Entities (Entity) (Kind) := null;
            end if;
         end loop;
      end Unset_Components;
   begin
      if not Registery.Has (Entity) then
         return;
      end if;

      case Components.Selection_Kind is
         when Selection_Package.Inclusive | Selection_Package.Inclusive_Or_None =>
            Unset_Components;
         when Selection_Package.Exclusive =>
            if Registery.Has (Entity, Components) then
               Unset_Components;
            end if;
      end case;
   end Unset;

   procedure Unset
     (Registery  : in out Registery_Type;
      Components :        Selection_Package.Selection_Type)
   is
   begin
      for Entity_Cursor in Registery.Entities.Iterate loop
         Registery.Unset (Entity_Component_Hashed_Maps.Key (Entity_Cursor), Components);
      end loop;
   end Unset;

   function Has
     (Registery : Registery_Type;
      Entity    : Entity_Type;
      Component : Component_Package.Component_Kind_Type)
      return Boolean
   is
      use type Component_Package.Component_Interface_Class_Access_Type;
   begin
      if not Registery.Has (Entity) then
         return False;
      end if;

      return Registery.Entities (Entity) (Component) /= null;
   end Has;

   function Has
     (Registery  : Registery_Type;
      Entity     : Entity_Type;
      Components : Selection_Package.Selection_Type)
      return Boolean
   is
      use type Selection_Package.Selection_Type;

      Entity_Components : Component_Package.Component_Boolean_Array_Type;
   begin
      if not Registery.Has (Entity) then
         return False;
      end if;

      Entity_Components := Registery.Get_Set_Components (Entity);

      return Components = Entity_Components;
   end Has;

   function Get
     (Registery : Registery_Type;
      Entity    : Entity_Type;
      Component : Component_Package.Component_Kind_Type)
      return Component_Package.Component_Interface_Class_Access_Type
   is
   begin
      if not Registery.Has (Entity) then
         return null;
      end if;

      return Registery.Entities (Entity) (Component);
   end Get;

   function Get_Set_Components
     (Registery : Registery_Type;
      Entity    : Entity_Type)
      return Component_Package.Component_Boolean_Array_Type
   is
      Components : Component_Package.Component_Boolean_Array_Type := (others => False);
   begin
      if not Registery.Has (Entity) then
         return Components;
      end if;

      for Component_Kind in Component_Package.Component_Kind_Type loop
         Components (Component_Kind) := Registery.Has (Entity, Component_Kind);
      end loop;

      return Components;
   end Get_Set_Components;

   ------------
   -- System --
   ------------
   procedure Each
     (Registery  : in out Registery_Type;
      Components :        Selection_Package.Selection_Type;
      System     :        System_Type)
   is
      Entity : Entity_Type;
   begin
      for Cursor in Registery.Entities.Iterate loop
         Entity := Entity_Component_Hashed_Maps.Key (Cursor);
         if Registery.Has
             (Entity     => Entity,
              Components => Components) then
            System (Registery, Entity);
         end if;
      end loop;
   end Each;

   procedure Each
     (Registery : in out Registery_Type;
      System    :        System_Type)
   is
   begin
      for Cursor in Registery.Entities.Iterate loop
         System (Registery, Entity_Component_Hashed_Maps.Key (Cursor));
      end loop;
   end Each;

   -------------
   -- Private --
   -------------

   function Hash_Entity
     (Entity : Entity_Type)
      return Ada.Containers.Hash_Type
   is
   begin
      return Ada.Containers.Hash_Type (Entity);
   end Hash_Entity;

end Internal.Generic_Registery;
