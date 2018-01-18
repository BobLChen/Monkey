/**
 * VERSION: 12.0
 * DATE: 2012-02-14
 * AS3 
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
package com.greensock.plugins {
	import com.greensock.TweenLite;
/**
 * [AS3/AS2 only] To tween any rotation property of the target object in the shortest direction, use "shortRotation" 
 * For example, if <code>myObject.rotation</code> is currently 170 degrees and you want to tween it to -170 degrees, 
 * a normal rotation tween would travel a total of 340 degrees in the counter-clockwise direction, 
 * but if you use shortRotation, it would travel 20 degrees in the clockwise direction instead. You 
 * can define any number of rotation properties in the shortRotation object which makes 3D tweening
 * easier, like:<br /><br /><code> 
 * 		
 * 		TweenMax.to(mc, 2, {shortRotation:{rotationX:-170, rotationY:35, rotationZ:200}}); <br /><br /></code>
 * 
 * Normally shortRotation is defined in degrees, but if you prefer to have it work with radians instead,
 * simply set the <code>useRadians</code> special property to <code>true</code> like:<br /><br /><code>
 * 
 * 		TweenMax.to(myCustomObject, 2, {shortRotation:{customRotationProperty:Math.PI, useRadians:true}});</code><br /><br />
 * 
 * <b>USAGE:</b><br /><br />
 * <code>
 * 		import com.greensock.TweenLite; <br />
 * 		import com.greensock.plugins.TweenPlugin; <br />
 * 		import com.greensock.plugins.ShortRotationPlugin; <br />
 * 		TweenPlugin.activate([ShortRotationPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.<br /><br />
 * 
 * 		TweenLite.to(mc, 1, {shortRotation:{rotation:-170}});<br /><br />
	
 * 		//or for a 3D tween with multiple rotation values...<br />
 * 		TweenLite.to(mc, 1, {shortRotation:{rotationX:-170, rotationY:35, rotationZ:10}}); <br /><br />
 * </code>
 * 
 * <p><strong>Copyright 2008-2012, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
	public class ShortRotationPlugin extends TweenPlugin {
		/** @private **/
		public static const API:Number = 2; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		/** @private **/
		public function ShortRotationPlugin() {
			super("shortRotation");
			_overwriteProps.pop();
		}
		
		/** @private **/
		override public function _onInitTween(target:Object, value:*, tween:TweenLite):Boolean {
			if (typeof(value) == "number") {
				return false;
			}
			var useRadians:Boolean = Boolean(value.useRadians == true), start:Number; 
			for (var p:String in value) {
				if (p != "useRadians") {
					start = (target[p] is Function) ? target[ ((p.indexOf("set") || !("get" + p.substr(3) in target)) ? p : "get" + p.substr(3)) ]() : target[p];
					_initRotation(target, p, start, (typeof(value[p]) == "number") ? Number(value[p]) : start + Number(value[p].split("=").join("")), useRadians);
				}
			}
			return true;
		}
		
		/** @private **/
		public function _initRotation(target:Object, p:String, start:Number, end:Number, useRadians:Boolean=false):void {
			var cap:Number = useRadians ? Math.PI * 2 : 360,
				dif:Number = (end - start) % cap;
			if (dif != dif % (cap / 2)) {
				dif = (dif < 0) ? dif + cap : dif - cap;
			}
			_addTween(target, p, start, start + dif, p);
			_overwriteProps[_overwriteProps.length] = p;
		}	

	}
}