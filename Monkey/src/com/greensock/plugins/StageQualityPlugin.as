/**
 * VERSION: 12.0
 * DATE: 2012-01-14
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
package com.greensock.plugins {
	import com.greensock.TweenLite;
	import flash.display.Stage;
	import flash.display.StageQuality;
/**
 * [AS3 only] Sets the stage's <code>quality</code> to a particular value during a tween and another value after
 * the tween which can be useful for improving rendering performance in the Flash Player while things are animating. <br /><br />
 * 
 * <b>USAGE:</b><br /><br />
 * <code>
 * 		import com.greensock.TweenLite; <br />
 * 		import com.greensock.plugins.TweenPlugin; <br />
 * 		import com.greensock.plugins.StageQualityPlugin; <br />
 * 		import flash.display.StageQuality; <br />
 * 		TweenPlugin.activate([StageQualityPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.<br /><br />
 * 
 * 		TweenLite.to(mc, 1, {x:100, stageQuality:{stage:this.stage, during:StageQuality.LOW, after:StageQuality.HIGH}}); <br /><br />
 * </code>
 * 
 * <b>Copyright 2011, GreenSock. All rights reserved.</b> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
 * 
 * @author Jack Doyle, jack@greensock.com
 */
	public class StageQualityPlugin extends TweenPlugin {
		/** @private **/
		public static const API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		/** @private **/
		protected var _stage:Stage;
		/** @private **/
		protected var _during:String;
		/** @private **/
		protected var _after:String;
		/** @private **/
		protected var _tween:TweenLite;
		
		/** @private **/
		public function StageQualityPlugin() {
			super("stageQuality");
		}
		
		/** @private **/
		override public function _onInitTween(target:Object, value:*, tween:TweenLite):Boolean {
			if (!(value.stage is Stage)) {
				trace("You must define a 'stage' property for the stageQuality object in your tween.");
				return false;
			}
			_stage = value.stage as Stage;
			_tween = tween;
			_during = ("during" in value) ? value.during : StageQuality.MEDIUM;
			_after = ("after" in value) ? value.after : _stage.quality;
			return true;
		}
		
		/** @private **/
		override public function setRatio(v:Number):void {
			if ((v == 1 && _tween._duration == _tween._time) || (v == 0 && _tween._time == 0)) { //a changeFactor of 1 doesn't necessarily mean the tween is done - if the ease is Elastic.easeOut or Back.easeOut for example, they could hit 1 mid-tween. The reason we check to see if cachedTime is 0 is for from() tweens
				_stage.quality = _after;
			} else if (_stage.quality != _during) {
				_stage.quality = _during;
			}
		}

	}
}