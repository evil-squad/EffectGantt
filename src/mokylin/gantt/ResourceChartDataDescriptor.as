package mokylin.gantt
{
    import mx.collections.ICollectionView;
    import mx.events.CollectionEvent;
    import mx.core.EventPriority;
    import mokylin.gantt.supportClasses.MessageUtil;
    import mokylin.gantt.ResourceChart;
    import mx.logging.LogEventLevel;
    import mokylin.gantt.supportClasses.GanttProperties;
    import mokylin.utils.DataUtil;
    import mx.collections.IViewCursor;
    import mx.collections.errors.ItemPendingError;
    import mx.events.PropertyChangeEvent;
    import mx.events.CollectionEventKind;
    import mx.collections.CursorBookmark;
    import mx.utils.UIDUtil;
    import mokylin.gantt.*;

    [ExcludeClass]
    [ResourceBundle("mokylingantt")]
    public class ResourceChartDataDescriptor 
    {

        private var _resourceIdToResource:Object;
        private var _resourceToResourceId:Object;
        private var _isInvalidResourcesInfo:Boolean;
        private var _resourceIdToTasks:Object;
        private var _taskToResourceId:Object;
        private var _isInvalidTasksInfo:Boolean;
        private var _resourceIdField:String = "id";
        private var _resourceIdFunction:Function = null;
        private var _resources:ICollectionView;
        private var _tasks:ICollectionView;
        private var _taskResourceIdField:String = "resourceId";
        private var _taskResourceIdFunction:Function = null;

        public function ResourceChartDataDescriptor()
        {
            this._resourceIdToResource = {};
            this._resourceToResourceId = {};
            this._resourceIdToTasks = {};
            this._taskToResourceId = {};
            super();
            this._isInvalidResourcesInfo = true;
            this._isInvalidTasksInfo = true;
        }

        public function get resourceIdField():String
        {
            return this._resourceIdField;
        }

        public function set resourceIdField(value:String):void
        {
            this._resourceIdField = value;
            this._isInvalidResourcesInfo = true;
        }

        public function get resourceIdFunction():Function
        {
            return this._resourceIdFunction;
        }

        public function set resourceIdFunction(value:Function):void
        {
            this._resourceIdFunction = value;
            this._isInvalidResourcesInfo = true;
        }

        public function get resources():ICollectionView
        {
            return this._resources;
        }

		public function setResources(value:ICollectionView):void
        {
            if (this._resources == value)
            {
                return;
            }
            if (this._resources)
            {
                this._resources.removeEventListener(CollectionEvent.COLLECTION_CHANGE, this.resourceCollectionChangeHandler);
            }
            this._resources = value;
            if (this._resources)
            {
                this._resources.addEventListener(CollectionEvent.COLLECTION_CHANGE, this.resourceCollectionChangeHandler, false, (EventPriority.BINDING + 1));
            }
            this._isInvalidResourcesInfo = true;
        }

		public  function invalidateResourceInfo():void
        {
            this._isInvalidResourcesInfo = true;
        }

        public function get tasks():ICollectionView
        {
            return this._tasks;
        }

		public function setTasks(value:ICollectionView):void
        {
            if (this._tasks == value)
            {
                return;
            }
            if (this._tasks)
            {
                this._tasks.removeEventListener(CollectionEvent.COLLECTION_CHANGE, this.taskCollectionChangeHandler);
            }
            this._tasks = value;
            if (this._tasks)
            {
                this._tasks.addEventListener(CollectionEvent.COLLECTION_CHANGE, this.taskCollectionChangeHandler, false, (EventPriority.BINDING + 1));
            }
            this._isInvalidTasksInfo = true;
        }

        public function get taskResourceIdField():String
        {
            return this._taskResourceIdField;
        }

        public function set taskResourceIdField(value:String):void
        {
            this._taskResourceIdField = value;
            this._isInvalidTasksInfo = true;
        }

        public function get taskResourceIdFunction():Function
        {
            return this._taskResourceIdFunction;
        }

        public function set taskResourceIdFunction(value:Function):void
        {
            this._taskResourceIdFunction = value;
            this._isInvalidTasksInfo = true;
        }

        public function getTasks(resource:Object):Array
        {
            this.refresh();
            if (resource == null)
            {
                MessageUtil.log(ResourceChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.ILLEGAL_NULL_PARAMETER_MESSAGE, ["ResourceChartDataDescriptor.getTasks()", "resource"]);
                return null;
            }
            var resourceId:String = this.getResourceId(resource);
            if (resourceId == null || resourceId.length == 0)
            {
                return null;
            }
            return this._resourceIdToTasks[resourceId] as Array;
        }

        public function getResource(task:Object):Object
        {
            this.refresh();
            if (task == null)
            {
                MessageUtil.log(ResourceChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.ILLEGAL_NULL_PARAMETER_MESSAGE, ["ResourceChartDataDescriptor.getResource()", "task"]);
                return null;
            }
            var resourceId:String = this.getResourceIdOfTask(task);
            if (resourceId == null || resourceId.length == 0)
            {
                return null;
            }
            return this._resourceIdToResource[resourceId] as Object;
        }

        public function getResourceById(id:String):Object
        {
            this.refresh();
            if (id == null)
            {
                MessageUtil.log(ResourceChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.ILLEGAL_NULL_PARAMETER_MESSAGE, ["ResourceChartDataDescriptor.getResourceById()", "id"]);
                return null;
            }
            return this._resourceIdToResource[id];
        }

        private function getResourceIdOfTask(task:Object):String
        {
            var uid:String = this.itemToUID(task);
            var resourceId:Object = this._taskToResourceId[uid];
            if (resourceId == null)
            {
                resourceId = DataUtil.getFieldValue(task, this.taskResourceIdField, null, this.taskResourceIdFunction);
                if (resourceId != null)
                {
                    this._taskToResourceId[uid] = resourceId;
                }
            }
            return resourceId==null ? null : String(resourceId);
        }

		public function getResourceId(resource:Object, nullIfUnknown:Boolean=true):String
        {
            var uid:String = this.itemToUID(resource);
            var resourceId:Object = this._resourceToResourceId[uid];
            if (resourceId == null && !nullIfUnknown)
            {
                resourceId = DataUtil.getFieldValue(resource, this.resourceIdField, null, this.resourceIdFunction);
                if (resourceId != null)
                {
                    this._resourceToResourceId[uid] = resourceId;
                }
            }
            return resourceId==null ? null : String(resourceId);
        }

        private function refresh():void
        {
            var cursor:IViewCursor;
            if (this._isInvalidResourcesInfo && this._resources)
            {
                this._isInvalidResourcesInfo = false;
                this._resourceIdToResource = {};
                this._resourceToResourceId = {};
                cursor = this._resources.createCursor();
                while (!cursor.afterLast)
                {
                    this.addResource(cursor.current);
                    try
                    {
                        cursor.moveNext();
                    }
                    catch(e:ItemPendingError)
                    {
                        _isInvalidResourcesInfo = true;
                        break;
                    }
                }
            }
            if (this._isInvalidTasksInfo && this._tasks)
            {
                this._isInvalidTasksInfo = false;
                this._resourceIdToTasks = {};
                this._taskToResourceId = {};
                cursor = this._tasks.createCursor();
                while (!cursor.afterLast)
                {
                    this.addTask(cursor.current);
                    try
                    {
                        cursor.moveNext();
                    }
                    catch(e:ItemPendingError)
                    {
                        _isInvalidTasksInfo = true;
                        break;
                    }
                }
            }
        }

        private function addResource(resource:Object):void
        {
            if (resource == null)
            {
                return;
            }
            var resourceId:String = this.getResourceId(resource, false);
            if (resourceId == null)
            {
                return;
            }
            var r:* = this._resourceIdToResource[resourceId];
            if (r !== undefined && r != resource)
            {
                MessageUtil.log(ResourceChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.DUPLICATE_RESOURCE_ID_MESSAGE, [resourceId]);
            }
            this._resourceIdToResource[resourceId] = resource;
        }

        private function removeResource(resource:Object, resourceId:String=null):void
        {
            if (resource == null)
            {
                return;
            }
            var uid:String = this.itemToUID(resource);
            if (resourceId == null)
            {
                resourceId = this.getResourceId(resource);
            }
            if (resourceId != null)
            {
                delete this._resourceIdToResource[resourceId];
            }
            delete this._resourceToResourceId[uid];
        }

        private function addTask(task:Object):void
        {
            if (task == null)
            {
                return;
            }
            var resourceId:String = this.getResourceIdOfTask(task);
            var tasks:Array = (this._resourceIdToTasks[resourceId] as Array);
            if (tasks == null)
            {
                tasks = [task];
                this._resourceIdToTasks[resourceId] = tasks;
            }
            else
            {
                tasks.push(task);
            }
        }

        private function removeTask(task:Object, resourceId:String=null):void
        {
            var tasks:Array;
            if (task == null)
            {
                return;
            }
            var uid:String = this.itemToUID(task);
            if (resourceId == null)
            {
                resourceId = this.getResourceIdOfTask(task);
            }
            if (resourceId != null)
            {
                tasks = (this._resourceIdToTasks[resourceId] as Array);
                if (tasks != null)
                {
                    tasks.splice(tasks.indexOf(task), 1);
                    if (tasks.length == 0)
                    {
                        delete this._resourceIdToTasks[resourceId];
                    }
                }
            }
            delete this._taskToResourceId[uid];
        }

        private function resourceCollectionChangeHandler(event:CollectionEvent):void
        {
            var item:Object;
            var propertyChangeEvent:PropertyChangeEvent;
            var kind:String = event.kind;
            if (!this._isInvalidResourcesInfo)
            {
                if (kind == CollectionEventKind.RESET || kind == CollectionEventKind.REFRESH)
                {
                    this._isInvalidResourcesInfo = true;
                }
                else if (event.kind == CollectionEventKind.UPDATE)
				{
					for each (propertyChangeEvent in event.items)
					{
						this.resourceUpdateHandler(propertyChangeEvent);
					}
				}
				else if (event.kind == CollectionEventKind.ADD)
				{
					this.resourceAddHandler(event);
				}
				else if (event.kind == CollectionEventKind.REMOVE)
				{
					for each (item in event.items)
					{
						this.removeResource(item);
					}
				}
				else if (event.kind == CollectionEventKind.REPLACE)
				{
					for each (propertyChangeEvent in event.items)
					{
						this.removeResource(propertyChangeEvent.oldValue);
						this.addResource(propertyChangeEvent.newValue);
					}
				}
            }
        }

        private function resourceUpdateHandler(event:PropertyChangeEvent):void
        {
            var resource:Object = event.source;
            var oldResourceId:String = this._resourceToResourceId[resource];
            var value:Object = DataUtil.getFieldValue(resource, this.resourceIdField, null, this.resourceIdFunction);
            var newResourceId:String = value != null ? String(value) : null;
            if (oldResourceId != newResourceId)
            {
                this.removeResource(resource, oldResourceId);
                this.addResource(resource);
            }
        }

        private function resourceAddHandler(event:CollectionEvent):void
        {
            var item:Object;
            var cursor:IViewCursor;
            var length:int;
            var i:int;
            if (!event.items || event.items.length == 0)
            {
                return;
            }
            if (event.items[0] != null)
            {
                for each (item in event.items)
                {
                    this.addResource(item);
                }
            }
            else
            {
                cursor = this.resources.createCursor();
                length = event.items.length;
                try
                {
                    cursor.seek(CursorBookmark.FIRST, event.location, length);
                    i = 0;
                    while (i < length)
                    {
                        if (cursor.afterLast)
                        {
                            break;
                        }
                        this.addResource(cursor.current);
                        cursor.moveNext();
                        i++;
                    }
                }
                catch(e:ItemPendingError)
                {
                }
            }
        }

        private function taskCollectionChangeHandler(event:CollectionEvent):void
        {
            var item:Object;
            var propertyChangeEvent:PropertyChangeEvent;
            var kind:String = event.kind;
            if (!this._isInvalidTasksInfo)
            {
                if (kind == CollectionEventKind.RESET || kind == CollectionEventKind.REFRESH)
                {
                    this._isInvalidTasksInfo = true;
                }
                else if (event.kind == CollectionEventKind.UPDATE)
				{
					for each (propertyChangeEvent in event.items)
					{
						this.taskUpdateHandler(propertyChangeEvent);
					}
				}
				else if (event.kind == CollectionEventKind.ADD)
				{
					for each (item in event.items)
					{
						this.addTask(item);
					}
				}
				else if (event.kind == CollectionEventKind.REMOVE)
				{
					for each (item in event.items)
					{
						this.removeTask(item);
					}
				}
				else if (event.kind == CollectionEventKind.REPLACE)
				{
					for each (propertyChangeEvent in event.items)
					{
						this.removeTask(propertyChangeEvent.oldValue);
						this.addTask(propertyChangeEvent.newValue);
					}
				}
            }
        }

        private function taskUpdateHandler(event:PropertyChangeEvent):void
        {
            var task:Object = event.source;
            var uid:String = this.itemToUID(task);
            var oldResourceId:String = this._taskToResourceId[uid];
            var newResourceId:String = (DataUtil.getFieldValue(task, this.taskResourceIdField, null, this.taskResourceIdFunction) as String);
            if (oldResourceId != newResourceId)
            {
                this.removeTask(task, oldResourceId);
                this.addTask(task);
            }
        }

        private function itemToUID(item:Object):String
        {
            if (item == null)
            {
                return "null";
            }
            return UIDUtil.getUID(item);
        }
    }
}
