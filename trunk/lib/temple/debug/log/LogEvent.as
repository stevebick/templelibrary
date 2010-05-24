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
 */

/*
Copyright 2007 by the authors of asaplibrary, http://asaplibrary.org
Copyright 2005-2007 by the authors of asapframework, http://asapframework.org

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */

package temple.debug.log 
{
	import temple.debug.getClassName;

	import flash.events.Event;

	/**
	 * Event dispatched when someting is logged. You can listen for this Event if you want to create your own Logger.
	 * 
	 * @author Thijs Broerse (adapted from ASAPLibrary)
	 */
	public class LogEvent extends Event 
	{
		/**
		 * Event type
		 */
		public static const EVENT:String = "LogEvent.Event";

		private var _level:String;
		private var _data:*;
		private var _sender:String;
		private var _objectId:uint;

		/**
		 * Creates a new LogEvent.
		 * @param level the level of the LogEvent.
		 * @param data data send with the Log message
		 * @param sender the 'toString' of the object that send the log message
		 * @param objectId the id of the object. The id is generated by the Registry.
		 */
		public function LogEvent(level:String, data:*, sender:String, objectId:uint) 
		{
			super(EVENT);
			
			this._level = level;
			this._data = data;
			this._sender = sender;
			this._objectId = objectId;
		}

		/**
		 * Returns the level of the Event.
		 * @see temple.debug.log.LogLevels
		 */
		public function get level():String
		{
			return this._level;
		}
		
		/**
		 * The data send with the Log message
		 */
		public function get data():*
		{
			return this._data;
		}
		
		/**
		 * The 'toString' of the object that send the log message
		 */
		public function get sender():String
		{
			return this._sender;
		}
		
		/**
		 * The id of the object that send the log message. The id is generated by the Registry.
		 * With the id you can get the object at the Registry
		 * @see temple.debug.Registry#getObject()
		 */
		public function get objectId():uint
		{
			return this._objectId;
		}
		
		/**
		 * Creates a copy of an existing LogEvent.
		 */
		override public function clone():Event 
		{
			return new LogEvent(this._level, this._data, this._sender, this._objectId);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function toString():String 
		{
			return getClassName(this) + ": level=" + this._level + "; data=" + this._data + "; sender=" + this._sender + "; objetId=" + this.objectId;
		} 
	}
}