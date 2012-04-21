/*
 *	Temple Library for ActionScript 3.0
 *	Copyright © MediaMonks B.V.
 *	All rights reserved.
 *	
 *	Redistribution and use in source and binary forms, with or without
 *	modification, are permitted provided that the following conditions are met:
 *	1. Redistributions of source code must retain the above copyright
 *	   notice, this list of conditions and the following disclaimer.
 *	2. Redistributions in binary form must reproduce the above copyright
 *	   notice, this list of conditions and the following disclaimer in the
 *	   documentation and/or other materials provided with the distribution.
 *	3. All advertising materials mentioning features or use of this software
 *	   must display the following acknowledgement:
 *	   This product includes software developed by MediaMonks B.V.
 *	4. Neither the name of MediaMonks B.V. nor the
 *	   names of its contributors may be used to endorse or promote products
 *	   derived from this software without specific prior written permission.
 *	
 *	THIS SOFTWARE IS PROVIDED BY MEDIAMONKS B.V. ''AS IS'' AND ANY
 *	EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *	DISCLAIMED. IN NO EVENT SHALL MEDIAMONKS B.V. BE LIABLE FOR ANY
 *	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *	
 *	
 *	Note: This license does not apply to 3rd party classes inside the Temple
 *	repository with their own license!
 */

package temple.mediaplayers.audio 
{
	import temple.core.events.CoreEventDispatcher;

	import flash.events.Event;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.net.URLRequest;

	[Event(name="AudioMetaDataEvent.metadata", type="temple.mediaplayers.audio.AudioMetaDataEvent")]
	[Event(name="AudioMetaDataEvent.notFound", type="temple.mediaplayers.audio.AudioMetaDataEvent")]

	/**
	 * @author Arjan van Wijk
	 */
	public class AudioInfoLoader extends CoreEventDispatcher 
	{
		private var _sound:Sound;
		private var _metadata:Object;

		public function AudioInfoLoader(metadata:Object = null)
		{
			this._metadata = metadata;
		}

		public function getMetaData(url:String):void
		{
			this._sound = new Sound();
			this._sound.addEventListener(Event.ID3, this.handleID3Loaded);
			this._sound.addEventListener(Event.COMPLETE, this.handleComplete);
			this._sound.load(new URLRequest(url));
		}
		
		private function handleID3Loaded(event:Event):void
		{
		}
		
		private function handleComplete(event:Event):void
		{
			var id3:ID3Info = this._sound.id3;
			
			if (id3['TLEN'] == undefined) id3['TLEN'] = this._sound.length;
			
			var audioMetaData:AudioMetaData = new AudioMetaData(id3);
			audioMetaData.parseObject(this._metadata);
			this.dispatchEvent(new AudioMetaDataEvent(AudioMetaDataEvent.METADATA, audioMetaData));
		}
		
		override public function destruct():void
		{
			if (this._sound)
			{
				this._sound.removeEventListener(Event.ID3, this.handleID3Loaded);
				this._sound = null;
			}
			
			super.destruct();
		}
	}
}