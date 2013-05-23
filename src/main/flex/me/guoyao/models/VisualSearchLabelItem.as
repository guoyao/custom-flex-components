package me.guoyao.models
{
	import mx.collections.IList;

	[DefaultProperty("list")]
	public class VisualSearchLabelItem
	{
		public function VisualSearchLabelItem(label:String = null, value:String = null, list:IList = null, multiSelectAble:Boolean = false)
		{
			this.label = label;
			this.value = value;
			this.list = list;
			this.multiSelectAble = multiSelectAble;
		}
		
		[Bindable]
		public var label:String;
		
		[Bindable]
		public var value:String;
		
		[Bindable]
		public var multiSelectAble:Boolean;
		
		[Bindable]
		public var list:IList; // vo collection
		
		public function reset():void
		{
			if(list)
			{
				for each(var item:ISelectAble in list)
				{
					item.selected = false;
				}
			}
		}
	}
}