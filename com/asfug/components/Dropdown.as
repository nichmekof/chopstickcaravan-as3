﻿package com.asfug.components 
{
	import com.asfug.events.DropdownEvent;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Ed Moore
	 */
	public class Dropdown extends EventDispatcher
	{
		public static const DOWN:String = 'down';
		public static const UP:String = 'up';
		
		private var _mc:MovieClip;
		private var _itemArray:Array;
		private var _dropdownItem:Class;
		private var _direction:String;
		private var _dropdownOpen:Boolean;
		private var _title:TextField;
		private var _selectedIndex:int;
		private var _maskHeight:int;
		
		private var _itemsMc:Sprite;
		private var _mask:Shape;
		private var _barHeight:Number;
		
		public function Dropdown(mc:MovieClip, items:Array, dropdownItem:Class, defaultText:String = 'Please Select', direction:String = Dropdown.DOWN, maskHeight:int = 0 ) 
		{
			_mc = mc;
			_barHeight = _mc.height;
			
			items.unshift( { label:defaultText, data:'' } );
			_itemArray = items;
			_dropdownItem = dropdownItem;
			_direction = direction;
			_maskHeight = maskHeight;
			
			_selectedIndex = 0;
			_dropdownOpen = false;
			
			_title = _mc.getChildByName('title_txt') as TextField;
			_title.text = defaultText;
			
			_mc.addEventListener(MouseEvent.CLICK, dropDownClicked, false, 0, true);
			//_mc.addEventListener(MouseEvent.MOUSE_OUT, mouseOut, false, 0, true);
			_mc.buttonMode = true;
		}
		
		/*private function mouseOut(e:MouseEvent):void 
		{
			closeDropDown();
		}*/
		
		private function dropDownClicked(e:MouseEvent):void 
		{
			if (_dropdownOpen)
				closeDropDown();
			else
				openDropDown();
		}
		
		/**
		 * Opens drop down menu
		 */
		public function openDropDown():void
		{
			_itemsMc = new Sprite();
			_itemsMc.name = 'dropdownItems_mc';
			if (_direction == Dropdown.DOWN)
			{
				_itemsMc.y = _mc.height;
				
				var yPos:Number = 0;
				for (var i:int = 0; i < _itemArray.length; ++i) 
				{
					var item:MovieClip = new _dropdownItem();
					item.y = yPos;
					item.name = 'item_' + i;
					
					var title:TextField = item.getChildByName('title_txt') as TextField;						
					title.text = (typeof (_itemArray[i]) == "string" ? _itemArray[i] : _itemArray[i].label );
					
					item.addEventListener(MouseEvent.CLICK, itemSelected, false, 0, true);
					
					_itemsMc.addChild(item);
					yPos += item.height;
				}
				
				if (_maskHeight > 0 )
					createMask();
				
				_mc.addChild(_itemsMc);
			}
			_dropdownOpen = true;
			dispatchEvent(new DropdownEvent(DropdownEvent.OPENED_DROP_DOWN));
		}
		
		private function createMask():void
		{
			_mask = new Shape();
			_mask.name = 'masker';
			_mask.graphics.beginFill(0x000000);
			_mask.graphics.drawRect(0, 0, _itemsMc.width, _maskHeight);
			_mask.graphics.endFill();
			
			_mask.x = _itemsMc.x;
			_mask.y = _itemsMc.y;
			_mc.addChild(_mask);
			
			_itemsMc.mask = _mask;
			
			_itemsMc.addEventListener(Event.ENTER_FRAME, moveItems);
		}
		
		private function moveItems(e:Event):void 
		{
			if (_mask.mouseY > _maskHeight * 0.5)
			{
				if (_itemsMc.y <= (_mask.y - _itemsMc.height) + _maskHeight)
					_itemsMc.y = (_mask.y - _itemsMc.height) + _maskHeight;
				else
					_itemsMc.y += 0.2 * -(_mask.mouseY - _maskHeight * .5);
			}
			else if (_mask.mouseY < _maskHeight * 0.5)
			{
				if (_itemsMc.y >= _barHeight)
					_itemsMc.y = _barHeight;
				else
					_itemsMc.y += 0.2 * -(_mask.mouseY - _maskHeight * .5);
			}
		}
		
		private function itemSelected(e:MouseEvent):void 
		{
			var name:String = e.currentTarget.name;
			var si:int = int(name.split('_')[1]);
			if (_selectedIndex != si)
			{
				_selectedIndex = si;
				dispatchEvent(new DropdownEvent(DropdownEvent.ITEM_CHANGED));
			}
			_title.text = getSelectedLabel();
		}
		/**
		 * Closes the drop down menu
		 */
		public function closeDropDown():void
		{
			if (_mc.getChildByName('masker') as Shape)
			{
				_itemsMc.removeEventListener(Event.ENTER_FRAME, moveItems);
				_mc.removeChild(_mc.getChildByName('masker') as Shape);
			}
				
			if (_itemsMc)
			{
				while (_itemsMc.numChildren > 0)
				{
					var item:DisplayObject = _itemsMc.getChildAt(0);
					item.removeEventListener(MouseEvent.CLICK, itemSelected);
					_itemsMc.removeChildAt(0);
				}
				_mc.removeChild(_itemsMc);
				_itemsMc = undefined;
			}
			
			_dropdownOpen = false;
			dispatchEvent(new DropdownEvent(DropdownEvent.CLOSED_DROP_DOWN));
		}
		/**
		 * Gets the currently selected items index
		 * @return	Selected item index value
		 */
		public function getSelectedIndex():int { return _selectedIndex; }
		/**
		 * Gets the currently selected items name
		 * @return	Selected item name
		 */
		public function getSelectedLabel():String 
		{ 
			if (typeof (_itemArray[_selectedIndex]) == "string")
				return _itemArray[_selectedIndex]; 
			else
				return _itemArray[_selectedIndex].label;
		}
		/**
		 * Gets currently selected items data
		 * @return	Selected item data
		 */
		public function getSelectedData():String 
		{ 
			if (typeof (_itemArray[_selectedIndex]) == "string")
				return _itemArray[_selectedIndex]; 
			else
				return _itemArray[_selectedIndex].data;
		}
		
	}

}