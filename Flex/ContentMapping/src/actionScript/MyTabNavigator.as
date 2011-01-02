package actionScript
{
	import mx.containers.TabNavigator;
	import mx.core.Application;
	import flash.events.Event;

	public class MyTabNavigator extends TabNavigator
	{
		public function MyTabNavigator()
		{
			super();
			this.addEventListener(Event.CHANGE,manageTabs);
		}
		public function manageTabs(eventObj:Event):void{
			if(!Application.application.showMappings){
				tabBar.selectedIndex = 0;
			}
		}
	}
}