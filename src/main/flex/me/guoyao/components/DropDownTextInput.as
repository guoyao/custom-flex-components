package me.guoyao.components
{
	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.collections.IList;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.managers.IFocusManagerComponent;
	
	import spark.components.List;
	import spark.components.PopUpAnchor;
	import spark.components.TextInput;
	import spark.components.supportClasses.DropDownController;
	import spark.events.DropDownEvent;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;
	
	[Event(name = "open", type = "spark.events.DropDownEvent")]
	[Event(name = "close", type = "spark.events.DropDownEvent")]
	[Event(name="change", type="spark.events.IndexChangeEvent")]
	
	[Style(name = "dropDownDropShadowVisible", type = "Boolean", inherit = "no", theme = "spark")]
	[Style(name = "dropDownBorderAlpha", type = "Number", inherit = "no", theme = "spark", minValue = "0.0", maxValue = "1.0")]
	[Style(name = "dropDownBorderColor", type = "uint", format = "Color", inherit = "no", theme = "spark")]
	[Style(name = "dropDownBorderVisible", type = "Boolean", inherit = "no", theme = "spark")]
	[Style(name = "dropDownContentBackgroundAlpha", type = "Number", inherit = "yes", theme = "spark", minValue = "0.0", maxValue = "1.0")]
	[Style(name = "dropDownContentBackgroundColor", type = "uint", format = "Color", inherit = "yes", theme = "spark")]
	
	[SkinState("open")]
	
	[DefaultProperty("dataProvider")]
	
	public class DropDownTextInput extends TextInput
	{
		public function DropDownTextInput()
		{
			super();
			dropDownController = new DropDownController();
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(TextOperationEvent.CHANGING, changingHandler);
		}
		
		[Bindable]
		public var dataProvider:IList;
		
		/**
		 * is dropdown multi-select
		 * */
		[Bindable]
		public var multiSelectAble:Boolean;
		
		/**
		 * formatted text after select operation complete
		 * */
		[Bindable]
		public var label:String;
		
		/**
		 * label field for dropdown
		 * */
		[Bindable]
		public var labelField:String = "label";
		
		[SkinPart(required = "true", type="spark.components.PopUpAnchor")]
		public var popUp:PopUpAnchor;
		
		[SkinPart(required = "true", type="flash.display.DisplayObject")]
		public var dropDown:DisplayObject;
		
		[SkinPart(required = "true", type = "spark.components.List")]
		public var list:List;
		
		private var _autoFocus:Boolean; //

		/**
		 * is auto setFocus after init
		 * */
		public function set autoFocus(value:Boolean):void
		{
			_autoFocus = value;
			if(value)
				addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}

		public function get isDropDownOpen():Boolean
		{
			if(dropDownController)
				return dropDownController.isOpen;
			else
				return false;
		}
		
		public function openDropDown():void
		{
			dropDownController.openDropDown();
		}
		
		public function closeDropDown(commit:Boolean):void
		{
			dropDownController.closeDropDown(commit);
		}
		
		private var _dropDownController:DropDownController;
		
		protected function get dropDownController():DropDownController
		{
			return _dropDownController;
		}
		
		protected function set dropDownController(value:DropDownController):void
		{
			if(_dropDownController == value)
				return;
			
			_dropDownController = value;
			
			_dropDownController.addEventListener(DropDownEvent.OPEN, dropDownController_openHandler);
			_dropDownController.addEventListener(DropDownEvent.CLOSE, dropDownController_closeHandler);
			
			if(dropDown)
				_dropDownController.dropDown = dropDown;
		}
		
		protected function dropDownController_openHandler(event:DropDownEvent):void
		{
			addEventListener(FlexEvent.UPDATE_COMPLETE, open_updateCompleteHandler);
			invalidateSkinState();
		}
		
		protected function open_updateCompleteHandler(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.UPDATE_COMPLETE, open_updateCompleteHandler);
			dispatchEvent(new DropDownEvent(DropDownEvent.OPEN));
		}
		
		protected function dropDownController_closeHandler(event:DropDownEvent):void
		{
			if(list && list.dataProvider && list.dataProvider.length > 0)
				addEventListener(FlexEvent.UPDATE_COMPLETE, close_updateCompleteHandler);
			else
				dispatchEvent(new DropDownEvent(DropDownEvent.CLOSE));
			
			invalidateSkinState();
		}
		
		protected function close_updateCompleteHandler(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.UPDATE_COMPLETE, close_updateCompleteHandler);
			dispatchEvent(new DropDownEvent(DropDownEvent.CLOSE));
		}
		
		override protected function getCurrentSkinState():String
		{
			return !enabled ? "disabled" : isDropDownOpen ? "open" : "normal";
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == dropDown)
			{
				dropDown.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, mouseDownOutsideHandler);
				dropDown.addEventListener(FlexMouseEvent.MOUSE_WHEEL_OUTSIDE, mouseWheelOutsideHandler);
				if(dropDownController)
					dropDownController.dropDown = dropDown;
			}
			
			if(instance == list)
			{
				list.focusEnabled = false;
				list.useVirtualLayout = false;
				list.owner = this;
				list.addEventListener(IndexChangeEvent.CHANGE, dispatchEvent);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if(instance == dropDown)
			{
				dropDown.removeEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, mouseDownOutsideHandler);
				dropDown.removeEventListener(FlexMouseEvent.MOUSE_WHEEL_OUTSIDE, mouseWheelOutsideHandler);
				if(dropDownController)
					dropDownController.dropDown = null;
			}
			
			if(instance == list)
			{
				list.dataProvider = null;
				list.owner = null;
				list.removeEventListener(IndexChangeEvent.CHANGE, dispatchEvent);
			}
			
			super.partRemoved(partName, instance);
		}
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			openDropDown();
		}
		
		protected function mouseDownHandler(event:MouseEvent):void
		{
			openDropDown();
		}
		
		protected function changingHandler(event:TextOperationEvent):void
		{
			event.preventDefault();
		}
		
		private function creationCompleteHandler(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			setFocus();
		}
		
		private function mouseDownOutsideHandler(event:FlexMouseEvent):void
		{
			if(event.relatedObject != this.textDisplay)
			{
				mouseWheelOutsideHandler(event);
			}
		}
		
		private function mouseWheelOutsideHandler(event:FlexMouseEvent):void
		{
			closeDropDown(false);
			if(!(event.relatedObject is IFocusManagerComponent) && stage)
				stage.focus = null;
		}
	}
}