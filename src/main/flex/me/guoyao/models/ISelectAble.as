package me.guoyao.models
{
	public interface ISelectAble
	{
		[Bindable("propertyChange")]
		function get selected():Boolean;
		
		function set selected(value:Boolean):void;
	}
}