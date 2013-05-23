package me.guoyao.components
{
	import flash.events.Event;
	
	import me.guoyao.models.VisualSearchLabelItem;
	import me.guoyao.components.skins.VisualSearchSkin;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	
	import spark.components.SkinnableContainer;
	import spark.events.IndexChangeEvent;
	
	[DefaultProperty("dropDownDataProvider")]
	
	public class VisualSearch extends SkinnableContainer
	{
		public function VisualSearch()
		{
			super();
			height = 32;
			setStyle("skinClass", VisualSearchSkin);
		}
		
		[Bindable]
		public var labelField:String = "label";
		
		public function set dataProvider(value:IList):void
		{
			selectedDataProvider.removeAll();
			dropDownDataProvider.removeAll();
			if(value != null)
			{
				for each(var item:VisualSearchLabelItem in value)
				{
					dropDownDataProvider.addItem(item);
				}
			}
			dataProviderChangeHandler();
		}
		
		private var _selectedDataProvider:IList = new ArrayCollection();
		
		/**
		 * collection for selected conditions
		 * */
		[Bindable("dataProviderChange")]
		public function get selectedDataProvider():IList
		{
			return _selectedDataProvider;
		}

		private var _dropDownDataProvider:IList = new ArrayCollection();
		
		/**
		 * collection for unselected conditions
		 * */
		[Bindable("dataProviderChange")]
		public function get dropDownDataProvider():IList
		{
			return _dropDownDataProvider;
		}
		
		[SkinPart(required="true")]
		public var textInput:DropDownTextInput;
		
		public function closeDropDown(commit:Boolean):void
		{
			textInput.closeDropDown(commit);
		}
		
		public function remove(item:VisualSearchLabelItem):void
		{
			item.reset();
			var index:int = selectedDataProvider.getItemIndex(item);
			selectedDataProvider.removeItemAt(index);
			dropDownDataProvider.addItem(item);
			dataProviderChangeHandler();
			textInput.closeDropDown(true);
//			textInput.setFocus();
		}
		
		public function clear():void
		{
			var item:VisualSearchLabelItem;
			for (var i:int = 0, length:int = selectedDataProvider.length; i < length; i++)
			{
				item = selectedDataProvider.getItemAt(i) as VisualSearchLabelItem;
				item.reset();
				selectedDataProvider.removeItemAt(i);
				dropDownDataProvider.addItem(item);
				i--;
				length--;
			}
			dataProviderChangeHandler();
			textInput.setFocus();
		}
		
		public function itemCloseHandler(item:VisualSearchLabelItem):void
		{
			var index:int = selectedDataProvider.getItemIndex(item);
			if(index == selectedDataProvider.length - 1)
			{
				textInput.setFocus();
			}
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == textInput)
			{
				textInput.owner = this;
				textInput.addEventListener(IndexChangeEvent.CHANGE, dropDownListChangeHandler);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if(instance == textInput)
			{
				textInput.owner = null;
				textInput.dataProvider = null;
				textInput.removeEventListener(IndexChangeEvent.CHANGE, dropDownListChangeHandler);
			}
			
			super.partRemoved(partName, instance);
		}
		
		private function dropDownListChangeHandler(event:IndexChangeEvent):void
		{
			var index:int = event.newIndex;
			var item:Object = dropDownDataProvider.getItemAt(index);
			dropDownDataProvider.removeItemAt(index);
			selectedDataProvider.addItem(item);
			dataProviderChangeHandler();
		}
		
		private function dataProviderChangeHandler():void
		{
			dispatchEvent(new Event("dataProviderChange"));
		}
	}
}