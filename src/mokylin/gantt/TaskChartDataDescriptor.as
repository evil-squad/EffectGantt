package mokylin.gantt
{
    import mx.collections.ICollectionView;
    import mx.events.CollectionEvent;
    import mx.core.EventPriority;
    import mokylin.gantt.supportClasses.MessageUtil;
    import mokylin.gantt.TaskChart;
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
    public class TaskChartDataDescriptor 
    {

        private var _taskIdToTask:Object;
        private var _taskToTaskId:Object;
        private var _isInvalidConstraintsInfo:Boolean;
        private var _taskIdToFromConstraints:Object;
        private var _taskIdToToConstraints:Object;
        private var _constraintToFromId:Object;
        private var _constraintToToId:Object;
        private var _isInvalidTasksInfo:Boolean;
        private var _constraintFromIdField:String = "fromId";
        private var _constraintFromIdFunction:Function = null;
        private var _constraintToIdField:String = "toId";
        private var _constraintToIdFunction:Function = null;
        private var _constraints:ICollectionView;
        private var _tasks:ICollectionView;
        private var _taskIdField:String = "id";
        private var _taskIdFunction:Function = null;

        public function TaskChartDataDescriptor()
        {
            this._taskIdToTask = {};
            this._taskToTaskId = {};
            this._taskIdToFromConstraints = {};
            this._taskIdToToConstraints = {};
            this._constraintToFromId = {};
            this._constraintToToId = {};
            super();
            this._isInvalidConstraintsInfo = true;
            this._isInvalidTasksInfo = true;
        }

        public function get constraintFromIdField():String
        {
            return this._constraintFromIdField;
        }

        public function set constraintFromIdField(value:String):void
        {
            this._constraintFromIdField = value;
            this._isInvalidConstraintsInfo = true;
        }

        public function get constraintFromIdFunction():Function
        {
            return this._constraintFromIdFunction;
        }

        public function set constraintFromIdFunction(value:Function):void
        {
            this._constraintFromIdFunction = value;
            this._isInvalidConstraintsInfo = true;
        }

        public function get constraintToIdField():String
        {
            return this._constraintToIdField;
        }

        public function set constraintToIdField(value:String):void
        {
            this._constraintToIdField = value;
            this._isInvalidConstraintsInfo = true;
        }

        public function get constraintToIdFunction():Function
        {
            return this._constraintToIdFunction;
        }

        public function set constraintToIdFunction(value:Function):void
        {
            this._constraintToIdFunction = value;
            this._isInvalidConstraintsInfo = true;
        }

        public function get constraints():ICollectionView
        {
            return this._constraints;
        }

		public function setConstraints(value:ICollectionView):void
        {
            if (this._constraints == value)
            {
                return;
            }
            if (this._constraints)
            {
                this._constraints.removeEventListener(CollectionEvent.COLLECTION_CHANGE, this.constraintCollectionChangeHandler);
            }
            this._constraints = value;
            if (this._constraints)
            {
                this._constraints.addEventListener(CollectionEvent.COLLECTION_CHANGE, this.constraintCollectionChangeHandler, false, (EventPriority.BINDING + 1));
            }
            this._isInvalidConstraintsInfo = true;
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

		public function invalidateTaskInfo():void
        {
            this._isInvalidTasksInfo = true;
        }

        public function get taskIdField():String
        {
            return this._taskIdField;
        }

        public function set taskIdField(value:String):void
        {
            this._taskIdField = value;
            this._isInvalidTasksInfo = true;
        }

        public function get taskIdFunction():Function
        {
            return this._taskIdFunction;
        }

        public function set taskIdFunction(value:Function):void
        {
            this._taskIdFunction = value;
            this._isInvalidTasksInfo = true;
        }

        public function getFromTask(constraint:Object):Object
        {
            this.refresh();
            if (constraint == null)
            {
                MessageUtil.log(TaskChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.ILLEGAL_NULL_PARAMETER_MESSAGE, ["TaskChartDataDescriptor.getFromTask()", "constraint"]);
                return null;
            }
            var taskId:String = this.getFromTaskId(constraint);
            if (taskId == null || taskId.length == 0)
            {
                return null;
            }
            return this._taskIdToTask[taskId];
        }

        public function getToTask(constraint:Object):Object
        {
            this.refresh();
            if (constraint == null)
            {
                MessageUtil.log(TaskChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.ILLEGAL_NULL_PARAMETER_MESSAGE, ["TaskChartDataDescriptor.getToTask()", "constraint"]);
                return null;
            }
            var taskId:String = this.getToTaskId(constraint);
            if (taskId == null || taskId.length == 0)
            {
                return null;
            }
            return this._taskIdToTask[taskId];
        }

        public function getFromConstraints(task:Object):Array
        {
            this.refresh();
            if (task == null)
            {
                MessageUtil.log(TaskChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.ILLEGAL_NULL_PARAMETER_MESSAGE, ["TaskChartDataDescriptor.getFromConstraints()", "task"]);
                return null;
            }
            var taskId:String = this.getTaskId(task);
            if (taskId == null || taskId.length == 0)
            {
                return null;
            }
            return this._taskIdToFromConstraints[taskId] as Array;
        }

        public function getToConstraints(task:Object):Array
        {
            this.refresh();
            if (task == null)
            {
                MessageUtil.log(TaskChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.ILLEGAL_NULL_PARAMETER_MESSAGE, ["TaskChartDataDescriptor.getToConstraints()", "task"]);
                return null;
            }
            var taskId:String = this.getTaskId(task);
            if (taskId == null || taskId.length == 0)
            {
                return null;
            }
            return this._taskIdToToConstraints[taskId] as Array;
        }

        public function getTaskById(id:String):Object
        {
            this.refresh();
            if (id == null)
            {
                MessageUtil.log(TaskChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.ILLEGAL_NULL_PARAMETER_MESSAGE, ["TaskChartDataDescriptor.getTaskById()", "id"]);
                return null;
            }
            return this._taskIdToTask[id];
        }

        private function getFromTaskId(constraint:Object):String
        {
            var uid:String = this.itemToUID(constraint);
            var taskId:Object = this._constraintToFromId[uid];
            if (taskId == null)
            {
                taskId = DataUtil.getFieldValue(constraint, this.constraintFromIdField, null, this.constraintFromIdFunction);
                if (taskId != null)
                {
                    this._constraintToFromId[uid] = taskId;
                }
            }
            return taskId==null ? null : String(taskId);
        }

        private function getToTaskId(constraint:Object):String
        {
            var uid:String = this.itemToUID(constraint);
            var taskId:Object = this._constraintToToId[uid];
            if (taskId == null)
            {
                taskId = DataUtil.getFieldValue(constraint, this.constraintToIdField, null, this.constraintToIdFunction);
                if (taskId != null)
                {
                    this._constraintToToId[uid] = taskId;
                }
            }
            return taskId==null ? null : String(taskId);
        }

		public function getTaskId(task:Object, nullIfUnknown:Boolean=true):String
        {
            var uid:String = this.itemToUID(task);
            var taskId:Object = this._taskToTaskId[uid];
            if (taskId == null && !nullIfUnknown)
            {
                taskId = DataUtil.getFieldValue(task, this.taskIdField, null, this.taskIdFunction);
                if (taskId != null)
                {
                    this._taskToTaskId[uid] = taskId;
                }
            }
            return taskId==null ? null : String(taskId);
        }

        private function refresh():void
        {
            var cursor:IViewCursor;
            if (this._isInvalidTasksInfo && this._tasks)
            {
                this._isInvalidTasksInfo = false;
                this._taskIdToTask = {};
                this._taskToTaskId = {};
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
            if (this._isInvalidConstraintsInfo && this._constraints)
            {
                this._isInvalidConstraintsInfo = false;
                this._taskIdToFromConstraints = {};
                this._taskIdToToConstraints = {};
                this._constraintToFromId = {};
                this._constraintToToId = {};
                cursor = this._constraints.createCursor();
                while (!cursor.afterLast)
                {
                    this.addConstraint(cursor.current);
                    try
                    {
                        cursor.moveNext();
                    }
                    catch(e:ItemPendingError)
                    {
                        _isInvalidConstraintsInfo = true;
                        break;
                    }
                }
            }
        }

        private function addTask(task:Object):void
        {
            if (task == null)
            {
                return;
            }
            var taskId:String = this.getTaskId(task, false);
            if (taskId == null)
            {
                return;
            }
            if (this._taskIdToTask[taskId] !== undefined)
            {
                MessageUtil.log(TaskChart, LogEventLevel.WARN, GanttProperties.ELIXIR_GANTT_BUNDLE, GanttProperties.DUPLICATE_TASK_ID_MESSAGE, [taskId]);
            }
            this._taskIdToTask[taskId] = task;
        }

        private function removeTask(task:Object, taskId:String=null):void
        {
            if (task == null)
            {
                return;
            }
            var uid:String = this.itemToUID(task);
            if (taskId == null)
            {
                taskId = this.getTaskId(task);
            }
            if (taskId != null)
            {
                delete this._taskIdToTask[taskId];
            }
            delete this._taskToTaskId[uid];
        }

        private function addConstraint(constraint:Object):void
        {
            if (constraint == null)
            {
                return;
            }
            var taskId:String = this.getFromTaskId(constraint);
            var constraints:Array = (this._taskIdToFromConstraints[taskId] as Array);
            if (constraints == null)
            {
                constraints = [constraint];
                this._taskIdToFromConstraints[taskId] = constraints;
            }
            else
            {
                constraints.push(constraint);
            }
            taskId = this.getToTaskId(constraint);
            constraints = (this._taskIdToToConstraints[taskId] as Array);
            if (constraints == null)
            {
                constraints = [constraint];
                this._taskIdToToConstraints[taskId] = constraints;
            }
            else
            {
                constraints.push(constraint);
            }
        }

        private function removeConstraint(constraint:Object, fromTaskId:String=null, toTaskId:String=null):void
        {
            var constraints:Array;
            if (constraint == null)
            {
                return;
            }
            var uid:String = this.itemToUID(constraint);
            if (fromTaskId == null)
            {
                fromTaskId = this.getFromTaskId(constraint);
            }
            if (fromTaskId != null)
            {
                constraints = (this._taskIdToFromConstraints[fromTaskId] as Array);
                if (constraints != null)
                {
                    constraints.splice(constraints.indexOf(constraint), 1);
                    if (constraints.length == 0)
                    {
                        delete this._taskIdToFromConstraints[fromTaskId];
                    }
                }
            }
            if (toTaskId == null)
            {
                toTaskId = this.getToTaskId(constraint);
            }
            if (toTaskId != null)
            {
                constraints = (this._taskIdToToConstraints[toTaskId] as Array);
                if (constraints != null)
                {
                    constraints.splice(constraints.indexOf(constraint), 1);
                    if (constraints.length == 0)
                    {
                        delete this._taskIdToToConstraints[toTaskId];
                    }
                }
            }
            delete this._constraintToFromId[uid];
            delete this._constraintToToId[uid];
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
					this.taskAddHandler(event);
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
            var oldTaskId:String = this._taskToTaskId[task];
            var value:Object = DataUtil.getFieldValue(task, this.taskIdField, null, this.taskIdFunction);
            var newTaskId:String = value != null ? String(value) : null;
            if (oldTaskId != newTaskId)
            {
                this.removeTask(task, oldTaskId);
                this.addTask(task);
            }
        }

        private function taskAddHandler(event:CollectionEvent):void
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
                    this.addTask(item);
                }
            }
            else
            {
                cursor = this.tasks.createCursor();
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
                        this.addTask(cursor.current);
                        cursor.moveNext();
                        i++;
                    }
                }
                catch(e:ItemPendingError)
                {
                }
            }
        }

        private function constraintCollectionChangeHandler(event:CollectionEvent):void
        {
            var item:Object;
            var propertyChangeEvent:PropertyChangeEvent;
            var kind:String = event.kind;
            if (!this._isInvalidConstraintsInfo)
            {
                if (kind == CollectionEventKind.RESET || kind == CollectionEventKind.REFRESH)
                {
                    this._isInvalidConstraintsInfo = true;
                }
                else if (event.kind == CollectionEventKind.UPDATE)
				{
					for each (propertyChangeEvent in event.items)
					{
						this.constraintUpdateHandler(propertyChangeEvent);
					}
				}
				else if (event.kind == CollectionEventKind.ADD)
				{
					for each (item in event.items)
					{
						this.addConstraint(item);
					}
				}
				else if (event.kind == CollectionEventKind.REMOVE)
				{
					for each (item in event.items)
					{
						this.removeConstraint(item);
					}
				}
				else if (event.kind == CollectionEventKind.REPLACE)
				{
					for each (propertyChangeEvent in event.items)
					{
						this.removeConstraint(propertyChangeEvent.oldValue);
						this.addConstraint(propertyChangeEvent.newValue);
					}
				}
            }
        }

        private function constraintUpdateHandler(event:PropertyChangeEvent):void
        {
            var constraint:Object = event.source;
            var uid:String = this.itemToUID(constraint);
            var oldFromTaskId:String = this._constraintToFromId[uid];
            var newFromTaskId:String = (DataUtil.getFieldValue(constraint, this.constraintFromIdField, null, this.constraintFromIdFunction) as String);
            var oldToTaskId:String = this._constraintToToId[uid];
            var newToTaskId:String = (DataUtil.getFieldValue(constraint, this.constraintToIdField, null, this.constraintToIdFunction) as String);
            if (oldFromTaskId != newFromTaskId || oldToTaskId != newToTaskId)
            {
                this.removeConstraint(constraint, oldFromTaskId, oldToTaskId);
                this.addConstraint(constraint);
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
