/*
 *	 
 *	Temple Library for ActionScript 3.0
 *	Copyright © 2010 MediaMonks B.V.
 *	All rights reserved.
 *	
 *	http://code.google.com/p/templelibrary/
 *	
 *	Redistribution and use in source and binary forms, with or without
 *	modification, are permitted provided that the following conditions are met:
 *	
 *	- Redistributions of source code must retain the above copyright notice,
 *	this list of conditions and the following disclaimer.
 *	
 *	- Redistributions in binary form must reproduce the above copyright notice,
 *	this list of conditions and the following disclaimer in the documentation
 *	and/or other materials provided with the distribution.
 *	
 *	- Neither the name of the Temple Library nor the names of its contributors
 *	may be used to endorse or promote products derived from this software
 *	without specific prior written permission.
 *	
 *	
 *	Temple Library is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU Lesser General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *	
 *	Temple Library is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU Lesser General Public License for more details.
 *	
 *	You should have received a copy of the GNU Lesser General Public License
 *	along with Temple Library.  If not, see <http://www.gnu.org/licenses/>.
 *	
 *	
 *	Note: This license does not apply to 3rd party classes inside the Temple
 *	repository with their own license!
 *	
 */

package temple.ui.focus 
{
	import temple.core.CoreEventDispatcher;
	import temple.debug.DebugManager;
	import temple.debug.IDebuggable;
	import temple.debug.errors.TempleError;
	import temple.debug.errors.throwError;
	import temple.ui.IEnableable;
	import temple.utils.keys.KeyManager;

	import flash.events.FocusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	/**
	 * @eventType flash.events.KeyboardEvent.KEY_DOWN
	 */
	[Event(name = "keyDown", type = "flash.events.KeyboardEvent")]

	/**
	 * Class for managing focus on UI components that implement IFocusable.
	 * Use of this class overrides default tab button behavior. Only UI components added to an instance of this class can get focus through use of the tab key. Consecutive presses on the TAB key will cycle through the list of items in order of addition, unless a specific tab index has been set on any of them. With SHIFT-TAB the list is cycled in reversed order.
	 * @example
	 * Suppose two objects of type InputField have been defined on the timeline, with instance names "mcName" &amp; "mcEmail". Use the following code to allow focus management on them:
	 * <listing version="3.0">
	 * 	focusManager = new TabFocusManager();
	 * 	focusManager.add(this.mcName);
	 * 	focusManager.add(this.mcEmail);
	 * 	</listing>
	 * 	
	 * 	@author Thijs Broerse
	 */
	public class TabFocusManager extends CoreEventDispatcher implements IFocusable, IDebuggable, IEnableable
	{
		private var _items:Array;
		private var _loop:Boolean;
		private var _debug:Boolean;
		private var _enabled:Boolean = true;

		/**
		 * Constructor
		 */
		public function TabFocusManager(loop:Boolean = true) 
		{
			this._loop = loop;
			this._items = new Array();
			DebugManager.add(this);
		}

		/**
		 * Clear list of focus elements
		 */
		public function clear():void 
		{
			while (this._items.length) this.remove(ItemData(this._items.shift()).item);
		}

		/**
		 * Sets the focus to a specific element.
		 * @param inItem: previously added item
		 */
		public function setFocus(item:IFocusable):void 
		{
			item.focus = true;
		}

		/**
		 * Add an item for focus management; optionally set the tab index for the item.
		 * @param item item to be used in focus management
		 * @param position zero-based, optional. If ommitted (or set to -1), it will be added to the end of the list. If an element was already found at the position specifed, it will be inserted prior to the existing element
		 * @return Boolean indicating if addition was successfull.
		 */
		public function add(item:IFocusable, tabIndex:int = -1):Boolean 
		{
			// check if element exists
			if (item == null) 
			{
				throwError(new TempleError(this, "No element specified for addition"));
			}

			// check if already added	
			if (this.indexOf(item) != -1) 
			{
				this.logWarn("addElement: Element already in list: " + item);
				return false;
			}
			
			if (item is IEventDispatcher)
			{
				(item as IEventDispatcher).addEventListener(KeyboardEvent.KEY_DOWN, this.handleKeyDown);
				(item as IEventDispatcher).addEventListener(FocusEvent.KEY_FOCUS_CHANGE, this.handleKeyFocusChange);
			}
			
			// add element depending on value of position
			if (tabIndex == -1 || this._items.length == 0) 
			{
				this._items.push(new ItemData(item, tabIndex));
			}
			else 
			{
				var leni:int = this._items.length;
				var tempItem:ItemData;
				for (var i:int = 0;i < leni; i++)
				{
					tempItem = ItemData(this._items[i]);
					
					if (tempItem.position >= tabIndex || tempItem.position == -1)
					{
						this._items.splice(i, 0, new ItemData(item, tabIndex));
						break;
					}
					else if (i == leni - 1)
					{
						this._items.push(new ItemData(item, tabIndex));
					}
				}
			}
			return true;
		}

		/**
		 * Removes an element
		 */
		public function remove(item:IFocusable):void
		{
			if (item is IEventDispatcher)
			{
				(item as IEventDispatcher).removeEventListener(KeyboardEvent.KEY_DOWN, this.handleKeyDown);
				(item as IEventDispatcher).removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, this.handleKeyFocusChange);
			}
			for (var i:int = this._items.length - 1;i >= 0; i--) 
			{
				if (ItemData(this._items[i]).item == item)
				{
					ItemData(this._items.splice(i, 1)[0]).destruct();
					return;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get focus():Boolean
		{
			return this.getCurrentFocusIndex() != -1;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set focus(value:Boolean):void
		{
			var item:IFocusable = this.getCurrentFocusItem();
			
			if (value && !item)
			{
				if (this._items.length)
				{
					// check if shift key is pressed
					if (KeyManager.isDown(Keyboard.SHIFT))
					{
						ItemData(this._items[this._items.length - 1]).item.focus = true;
					}
					else
					{
						ItemData(this._items[0]).item.focus = true;
					}
				}
			}
			else if (!value && item) item.focus = false;
		}
		
		/**
		 * A Boolean that indicates if tabbiing should loop. If true, the first item will get the focus when tabbing on the last item.
		 * @default true
		 */
		public function get loop():Boolean
		{
			return this._loop;
		}
		
		/**
		 * @private
		 */
		public function set loop(value:Boolean):void
		{
			this._loop = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function enable():void
		{
			this._enabled = true;
		}

		/**
		 * @inheritDoc
		 */
		public function disable():void
		{
			this._enabled = false;
		}

		/**
		 * @inheritDoc
		 */
		public function get enabled():Boolean
		{
			return this._enabled;
		}

		/**
		 * @inheritDoc
		 */
		public function set enabled(value:Boolean):void
		{
			this._enabled = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get debug():Boolean
		{
			return this._debug;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set debug(value:Boolean):void
		{
			this._debug = value;
		}
		
		private function handleKeyDown(event:KeyboardEvent):void
		{
			if (this._enabled && event.keyCode == Keyboard.TAB)
			{
				if (this.debug) this.logDebug("handleKeyDown: tab received from: " + event.target + ", through: " + event.currentTarget);
				
				if (event.shiftKey)
				{
					if (this._loop || this.getCurrentFocusIndex() > 0)
					{
						event.stopImmediatePropagation();
						this.focusPreviousItem();
					}
					else
					{
						this.dispatchEvent(event.clone());
					}
				}
				else if (this._loop || this.getCurrentFocusIndex() < this._items.length - 1)
				{
					event.stopImmediatePropagation();
					this.focusNextItem();
				}
				else
				{
					this.dispatchEvent(event.clone());
				}
			}
		}

		/**
		 * Set focus to next item in list.
		 */
		private function focusNextItem():void 
		{
			if (this.debug) this.logDebug("focusNextItem: ");
			
			// check if focus is in current list
			var index:Number = this.getCurrentFocusIndex();
			if (index == -1) return;
	
			// store previous focus
			var prev:Number = index;
			
			var item:IFocusable;
			
			while (item == null)
			{
				// increment & check limit
				index++;
				if (index > this._items.length - 1) index = 0;
				
				if (item == prev)
				{
					// we checked all items, no next item found
					return;
				}
				
				item = ItemData(this._items[index]).item;
				
				// check if new item is enabled, if not, set to null so we check next
				if (item is IEnableable && IEnableable(item).enabled == false)
				{
					item = null;
				}
			}
			item.focus = true;
		}

		/**
		 * Set focus to previous item in list.
		 */
		private function focusPreviousItem():void 
		{
			if (this.debug) this.logDebug("focusPreviousItem: ");
			
			// check if focus is in current list
			var index:Number = this.getCurrentFocusIndex();
			if (index == -1) return;
	
			// store previous focus
			var prev:Number = index;
			
			var item:IFocusable;
			
			while (item == null)
			{
				// decrement & check limit
				index--;
				if (index < 0) index = this._items.length - 1;
				
				if (item == prev)
				{
					// we checked all items, no next item found
					return;
				}
				
				item = ItemData(this._items[index]).item;
				
				// check if new item is enabled, if not, set to null so we check next
				if (item is IEnableable && IEnableable(item).enabled == false)
				{
					item = null;
				}
			}
			item.focus = true;
		}

		/**
		 * Checks if any of our elements has focus and returns its index
		 * @return the index of the current item, or -1 if none was found
		 */
		private function getCurrentFocusIndex():int 
		{
			if (!this._items) return -1;
			
			var len:uint = this._items.length;
			for (var i:int = 0;i < len; ++i) 
			{
				if (ItemData(this._items[i]).item.focus) return i;
			}
			return -1;
		}

		private function getCurrentFocusItem():IFocusable 
		{
			var len:uint = this._items.length;
			for (var i:int = 0;i < len; ++i) 
			{
				if (ItemData(this._items[i]).item.focus) return ItemData(this._items[i]).item;
			}
			return null;
		}

		private function indexOf(item:IFocusable):int
		{
			var leni:int = this._items.length;
			for (var i:int = 0;i < leni; i++)
			{
				if (ItemData(this._items[i]).item == item) return i;
			}
			return -1;
		}
		
		private function handleKeyFocusChange(event:FocusEvent):void 
		{
			event.preventDefault();
		}

		/**
		 * @inheritDoc
		 */
		override public function destruct():void
		{
			if (this._items)
			{
				this.clear();
				this._items = null;
			}
			
			super.destruct();
		}
	}
}

import temple.core.CoreObject;
import temple.ui.focus.IFocusable;

class ItemData extends CoreObject
{
	public var item:IFocusable;
	public var position:int;

	public function ItemData(item:IFocusable, position:int) 
	{
		this.toStringProps.push('position', 'item');
		this.item = item;
		this.position = position;
	}
	
	override public function destruct():void
	{
		this.item = null;
		super.destruct();
	}
}