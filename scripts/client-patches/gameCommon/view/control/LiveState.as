package gameCommon.view.control
{
   import catchInsect.InsectProBar;
   import catchInsect.event.InsectEvent;
   import com.greensock.TweenLite;
   import com.pickgliss.ui.ComponentFactory;
   import com.pickgliss.ui.LayerManager;
   import com.pickgliss.ui.controls.BaseButton;
   import com.pickgliss.utils.ClassUtils;
   import com.pickgliss.utils.ObjectUtils;
   import ddt.events.LivingEvent;
   import ddt.manager.PlayerManager;
   import ddt.manager.ServerConfigManager;
   import ddt.manager.SharedManager;
   import ddt.manager.SocketManager;
   import ddt.manager.SoundManager;
   import ddt.utils.PositionUtils;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   import game.GameDecorateManager;
   import game.GameManager;
   import gameCommon.GameControl;
   import gameCommon.model.GameInfo;
   import gameCommon.model.LocalPlayer;
   import gameCommon.view.EnergyView;
   import gameCommon.view.arrow.ArrowView;
   import gameCommon.view.prop.BossRightPropBar;
   import gameCommon.view.prop.CustomPropBar;
   import gameCommon.view.prop.HorseGameSkillBar;
   import gameCommon.view.prop.PetAvatarEnergyBar;
   import gameCommon.view.prop.PetSkillBar;
   import gameCommon.view.prop.RightPropBar;
   import gameCommon.view.prop.SoulMarkPropBar;
   import gameCommon.view.prop.WeaponPropBar;
   import gameCommon.view.tool.BossToolStripView;
   import gameCommon.view.tool.ToolStripView;
   import rescue.views.RescuePropBar;
   import road7th.utils.MovieClipWrapper;
   import room.RoomManager;
   import trainer.controller.NewHandGuideManager;
   import trainer.controller.WeakGuildManager;
   import trainer.view.NewHandContainer;

   public class LiveState extends ControlState
   {

      protected var _arrow:ArrowView;

      protected var _energy:EnergyView;

      protected var _customPropBar:CustomPropBar;

      protected var _tool:ToolStripView;

      protected var _rightPropBar:RightPropBar;

      protected var _weaponPropBar:WeaponPropBar;

      protected var _rescuePropBar:RescuePropBar;

      protected var _insectProBar:InsectProBar;

      protected var _bossPropBar:BossRightPropBar;

      protected var _horseSkillBar:HorseGameSkillBar;

      protected var _petSkill:PetSkillBar;

      protected var _petSkillIsShowBtn:BaseButton;

      protected var _petSkillBtnCurrentFrame:int;

      protected var _petSkillIsShowBtnTopY:Number;

      protected var _soulMarkSkillPro:SoulMarkPropBar;

      protected var _petAvatarBar:PetAvatarEnergyBar;

      private var _specialMisID:Array = [1277,1378,1348,300313,300323,300333,31004,300614,300624,300634,370104,370204,370304,370404,401004,402004,403004,404004];

      private var _gameInfo:GameInfo = GameControl.Instance.Current;

      public function LiveState(param1:LocalPlayer)
      {
         super(param1);
         GameManager.instance.isStopFocus = false;
      }

      override protected function configUI() : void
      {
         GameDecorateManager.Instance.createBitmapUI(this,"asset.gameDecorate.viewBg");
         _arrow = new ArrowView(_self);
         var _loc1_:Point = ComponentFactory.Instance.creatCustomObject("asset.game.ArrowViewPos");
         _arrow.x = _loc1_.x;
         _arrow.y = _loc1_.y;
         addChild(_arrow);
         _energy = new EnergyView(_self);
         var _loc3_:Point = ComponentFactory.Instance.creatCustomObject("asset.game.energyPos");
         _energy.x = _loc3_.x;
         _energy.y = _loc3_.y;
         addChild(_energy);
         if(RoomManager.Instance.current.type == 41 || RoomManager.Instance.current.type == 42)
         {
            _customPropBar = ComponentFactory.Instance.creatCustomObject("EntertainmentCustomPropBar",[_self,0]);
            addChild(_customPropBar);
         }
         else if(_gameInfo.missionInfo && (RoomManager.Instance.current.type == 11 || RoomManager.Instance.current.type == 21 || _gameInfo.missionInfo.isWorldCupI || _gameInfo.missionInfo.isWorldCupIII || _gameInfo.missionInfo.isNewFifthMissionIV || _gameInfo.missionInfo.isNewFifthMissionV || _gameInfo.missionInfo.isVehicleTankMission || _specialMisID.indexOf(_gameInfo.missionInfo.id) != -1) || RoomManager.Instance.current.type == 80 || RoomManager.Instance.current.type == 91 || RoomManager.Instance.current.type == 85 || RoomManager.Instance.current.type == 29 || isNeedProSkillBarByMissionID())
         {
            if(_gameInfo.missionInfo.id == 602001 || _gameInfo.missionInfo.id == 70301)
            {
               _horseSkillBar = new HorseGameSkillBar(_self);
               _horseSkillBar.x = 654;
               _horseSkillBar.y = 57;
               addChild(_horseSkillBar);
               _horseSkillBar.setVisible(false);
            }
            _customPropBar = ComponentFactory.Instance.creatCustomObject("LiveCustomPropBar",[_self,0]);
            addChild(_customPropBar);
         }
         else if(_gameInfo.missionInfo == null && (_gameInfo.gameMode == 56 || _gameInfo.gameMode == 71 || _gameInfo.gameMode == 100))
         {
            _customPropBar = ComponentFactory.Instance.creatCustomObject("LiveCustomPropBar",[_self,0]);
            addChild(_customPropBar);
         }
         else if(RoomManager.Instance.current.type == 52)
         {
            _insectProBar = ComponentFactory.Instance.creatCustomObject("catchInsect.propBar",[_self,0]);
            addChild(_insectProBar);
            _insectProBar.enter();
            _insectProBar.addEventListener("useProp",__useInsectProp);
         }
         else if(!_self.isCharacterMovie)
         {
            _horseSkillBar = new HorseGameSkillBar(_self);
            _horseSkillBar.x = 654;
            _horseSkillBar.y = 57;
            addChild(_horseSkillBar);
         }
         if(GameControl.Instance.Current.roomType == 105 || RoomManager.Instance.current.type == 105)
         {
            _customPropBar = ComponentFactory.Instance.creatCustomObject("LiveCustomPropBar",[_self,0]);
            addChild(_customPropBar);
            if(_rightPropBar)
            {
               _rightPropBar.hidePropBar();
            }
            if(_petSkill)
            {
               _petSkill.visible = false;
               _petSkillIsShowBtn.visible = false;
            }
            isHorseSkill(false);
         }
         if(_self.currentPet && !_self.isCharacterMovie && GameControl.Instance.Current.roomType != 120 && GameControl.Instance.Current.roomType != 59 && GameControl.Instance.Current.roomType != 123 && GameControl.Instance.Current.roomType != 151 && GameControl.Instance.Current.gameMode != 56 && GameControl.Instance.Current.gameMode != 57 && GameControl.Instance.Current.gameMode != 120 && GameControl.Instance.Current.gameMode != 124 && GameControl.Instance.Current.gameMode != 82 && GameControl.Instance.Current.roomType != 29)
         {
            _petSkill = new PetSkillBar(_self);
            PositionUtils.setPos(_petSkill,"asset.game.petskillBarPos");
            if(!(_gameInfo.missionInfo && _gameInfo.missionInfo.isWorldCupI))
            {
               addChild(_petSkill);
            }
            _petSkillIsShowBtn = ComponentFactory.Instance.creatComponentByStylename("game.petSkillBarIsShowBtn");
            MovieClip(_petSkillIsShowBtn.backgound).gotoAndStop(1);
            _petSkillBtnCurrentFrame = 1;
            _petSkillIsShowBtn.addEventListener("click",__onPetSillIsShowBtnClick);
            _petSkillIsShowBtn.addEventListener("rollOver",__onPetSillIsShowBtnOver);
            _petSkillIsShowBtn.addEventListener("rollOut",__onPetSillIsShowBtnOut);
            _petSkillIsShowBtn.addEventListener("mouseDown",__onPetSillIsShowBtnMousedown);
            if(!(_gameInfo.missionInfo && _gameInfo.missionInfo.isWorldCupI))
            {
               addChild(_petSkillIsShowBtn);
            }
            _petSkillIsShowBtnTopY = _petSkillIsShowBtn.y;
         }
         _weaponPropBar = ComponentFactory.Instance.creatCustomObject("WeaponPropBar",[_self]);
         if(!_gameInfo.missionInfo || !_gameInfo.missionInfo.isWorldCupI)
         {
            if(RoomManager.Instance.current.type == 29)
            {
               if(!_rescuePropBar)
               {
                  _rescuePropBar = new RescuePropBar();
                  PositionUtils.setPos(_rescuePropBar,"game.view.rescuePropBarPos");
               }
               addChild(_rescuePropBar);
               _weaponPropBar.setVisible(false);
            }
            else
            {
               addChild(_weaponPropBar);
            }
         }
         var _loc2_:int = GameControl.Instance.Current.getCurRoomTypeOfPVpPve();
         if(_loc2_ > 0)
         {
            if(!_soulMarkSkillPro)
            {
               _soulMarkSkillPro = new SoulMarkPropBar(_self);
               PositionUtils.setPos(_soulMarkSkillPro,"asset.game.soulMarkSkillBarPos");
               if(!(_gameInfo.missionInfo && _gameInfo.missionInfo.isWorldCupI))
               {
                  _soulMarkSkillPro.initView(_loc2_);
                  addChild(_soulMarkSkillPro);
               }
            }
         }
         if(RoomManager.Instance.current && (RoomManager.Instance.current.type == 18 || RoomManager.Instance.current.type == 120 || RoomManager.Instance.current.type == 123 || RoomManager.Instance.current.type == 151 || RoomManager.Instance.current.type == 82 || GameControl.Instance.Current.gameMode == 56 || GameControl.Instance.Current.gameMode == 57 || RoomManager.Instance.current.type == 92))
         {
            if(_petSkill)
            {
               _petSkill.visible = false;
               _petSkillIsShowBtn.visible = false;
            }
         }
         if(_self.isCharacterMovie)
         {
            _bossPropBar = new BossRightPropBar(_self,this);
            PositionUtils.setPos(_bossPropBar,"game.view.bossPropBarPos");
            _tool = new BossToolStripView();
            PositionUtils.setPos(_tool,"asset.game.bossToolPos");
         }
         else
         {
            _rightPropBar = ComponentFactory.Instance.creatCustomObject("RightPropBar",[_self,this]);
            _tool = new ToolStripView();
            PositionUtils.setPos(_tool,"asset.game.toolPos");
         }
         addChild(_tool);
         if((RoomManager.Instance.current.type == 88 || GameControl.Instance.isVehicleTankGame() || RoomManager.Instance.current.type == 112) && _rightPropBar)
         {
            _rightPropBar.hidePropBar();
         }
         if(GameControl.Instance.Current.getShowPabEnergyBar())
         {
            _petAvatarBar = new PetAvatarEnergyBar();
            PositionUtils.setPos(_petAvatarBar,"asset.game.petAvatarSkillBarPos");
            addChild(_petAvatarBar);
         }
         setPropBarVisible();
         super.configUI();
      }

      private function isNeedProSkillBarByMissionID() : Boolean
      {
         var _loc1_:Boolean = false;
         var _loc2_:Array = ServerConfigManager.instance.gameMissionNeedOpenItemField;
         if(_gameInfo.missionInfo && _loc2_.indexOf(String(_gameInfo.missionInfo.id)) != -1)
         {
            _loc1_ = true;
         }
         return _loc1_;
      }

      public function updateFlyCD() : void
      {
         _weaponPropBar.updateFlyCD();
      }

      public function updateSkillLockStatus(param1:int, param2:Boolean) : void
      {
         switch(param1)
         {
            case 0:
               if(_horseSkillBar)
               {
                  _horseSkillBar.lockState = param2;
               }
               break;
            case 1:
               if(_petSkill)
               {
                  _petSkill.lockState = param2;
               }
               if(RoomManager.Instance.current.type == 51 && _petSkill)
               {
                  _petSkill.enabled = param2;
               }
         }
      }

      protected function __useInsectProp(param1:InsectEvent) : void
      {
         if(_rightPropBar)
         {
            _rightPropBar.hidePropBar();
         }
         if(_bossPropBar)
         {
            _bossPropBar.hidePropBar();
         }
      }

      private function __onPetSillIsShowBtnOver(param1:MouseEvent) : void
      {
         MovieClip(_petSkillIsShowBtn.backgound).gotoAndStop(_petSkillBtnCurrentFrame);
      }

      private function __onPetSillIsShowBtnOut(param1:MouseEvent) : void
      {
         MovieClip(_petSkillIsShowBtn.backgound).gotoAndStop(_petSkillBtnCurrentFrame);
      }

      private function __onPetSillIsShowBtnMousedown(param1:MouseEvent) : void
      {
      }

      private function __onPetSillIsShowBtnClick(param1:MouseEvent) : void
      {
         SoundManager.instance.play("008");
         if(_petSkill == null)
         {
            return;
         }
         if(_petSkill.visible)
         {
            _petSkillBtnCurrentFrame = 2;
            _petSkill.visible = false;
            if(_customPropBar)
            {
               _petSkillIsShowBtn.y = _customPropBar.y - _petSkillIsShowBtn.height;
            }
            if(_horseSkillBar)
            {
               _petSkillIsShowBtn.y = _horseSkillBar.y - _petSkillIsShowBtn.height;
            }
         }
         else
         {
            _petSkillBtnCurrentFrame = 1;
            _petSkill.visible = true;
            _petSkillIsShowBtn.y = _petSkillIsShowBtnTopY;
         }
         MovieClip(_petSkillIsShowBtn.backgound).gotoAndStop(_petSkillBtnCurrentFrame);
      }

      private function setPropBarVisible() : void
      {
         if(_rightPropBar)
         {
            if(_gameInfo.missionInfo && _gameInfo.missionInfo.isWorldCupI || RoomManager.Instance.current.gameMode == 8 || RoomManager.Instance.current.type == 29 || RoomManager.Instance.current.type == 41 || RoomManager.Instance.current.type == 42 || RoomManager.Instance.current.type == 80 || RoomManager.Instance.current.type == 91 || RoomManager.Instance.current.type == 92)
            {
               _rightPropBar.hidePropBar();
            }
         }
      }

      override protected function addEvent() : void
      {
         SharedManager.Instance.addEventListener("transparentChanged",__transparentChanged);
         super.addEvent();
      }

      protected function __transparentChanged(param1:Event) : void
      {
         if(SharedManager.Instance.propTransparent)
         {
            this.alpha = 0.5;
         }
         else
         {
            this.alpha = 1;
         }
      }

      override protected function removeEvent() : void
      {
         SharedManager.Instance.removeEventListener("transparentChanged",__transparentChanged);
         super.removeEvent();
      }

      public function isHorseSkill(param1:Boolean) : void
      {
         if(_customPropBar)
         {
            _customPropBar.setVisibleOther(!param1);
         }
         if(_horseSkillBar)
         {
            _horseSkillBar.setVisible(param1);
         }
      }

      override public function enter(param1:DisplayObjectContainer) : void
      {
         if(_customPropBar)
         {
            _customPropBar.enter();
            if(!this.contains(_customPropBar))
            {
               addChild(_customPropBar);
            }
         }
         if(_horseSkillBar)
         {
            _horseSkillBar.enter();
         }
         _weaponPropBar.enter();
         if(!this.contains(_weaponPropBar) && !(GameControl.Instance.Current.missionInfo && GameControl.Instance.Current.missionInfo.isWorldCupI) && RoomManager.Instance.current.type != 29)
         {
            addChild(_weaponPropBar);
         }
         _energy.enter();
         _arrow.enter();
         if(_rightPropBar)
         {
            _rightPropBar.setup(param1);
            _rightPropBar.enter();
         }
         if(_bossPropBar)
         {
            _bossPropBar.setup(param1);
            _bossPropBar.enter();
         }
         if(_soulMarkSkillPro)
         {
            _soulMarkSkillPro.enter();
         }
         _gameInfo = GameControl.Instance.Current;
         if(WeakGuildManager.Instance.switchUserGuide)
         {
            loadWeakGuild();
         }
         if(RoomManager.Instance.current.type == 29 || RoomManager.Instance.current.type == 52)
         {
            _tool.setDanderEnable(false);
         }
         if(GameControl.Instance.Current.roomType == 105 || RoomManager.Instance.current.type == 105)
         {
            if(_rightPropBar)
            {
               _rightPropBar.hidePropBar();
            }
            if(_petSkill)
            {
               _petSkill.visible = false;
               _petSkillIsShowBtn.visible = false;
            }
            isHorseSkill(false);
         }
         __transparentChanged(null);
         super.enter(param1);
      }

      override public function leaving(param1:Function = null) : void
      {
         if(_customPropBar)
         {
            _customPropBar.leaving();
         }
         if(_insectProBar)
         {
            _insectProBar.leaving();
            _insectProBar.removeEventListener("useProp",__useInsectProp);
         }
         if(_horseSkillBar)
         {
            _horseSkillBar.leaving();
         }
         if(_rightPropBar)
         {
            _rightPropBar.leaving();
         }
         if(_bossPropBar)
         {
            _bossPropBar.leaving();
         }
         _weaponPropBar.leaving();
         ObjectUtils.disposeObject(_rescuePropBar);
         _rescuePropBar = null;
         _energy.leaving();
         _arrow.leaving();
         super.leaving(param1);
      }

      override protected function tweenIn() : void
      {
         y = 600;
         TweenLite.to(this,0.3,{"y":498});
      }

      protected function loadWeakGuild() : void
      {
         setWeaponPropVisible(PlayerManager.Instance.Self.IsWeakGuildFinish(11));
         _tool.setDanderEnable(PlayerManager.Instance.Self.IsWeakGuildFinish(10));
         if(NewHandGuideManager.Instance.mapID == 111)
         {
            setArrowVisible(false);
            setEnergyVisible(false);
            setSelfPropBarVisible(false);
         }
         if(PlayerManager.Instance.Self.IsWeakGuildFinish(5))
         {
            if(!PlayerManager.Instance.Self.IsWeakGuildFinish(6))
            {
               setTimeout(propOpenShow,2000,"asset.trainer.getAddTenPercent");
               _gameInfo.selfGamePlayer.addEventListener("attackingChanged",__showTenPersentArrow);

            }
         }
         else
         {
            setRightPropVisible(false,7);
         }
         if(!PlayerManager.Instance.Self.IsWeakGuildFinish(2))
         {
            setRightPropVisible(false,2);
         }
         if(PlayerManager.Instance.Self.IsWeakGuildFinish(12))
         {
            if(!PlayerManager.Instance.Self.IsWeakGuildFinish(23))
            {
               setTimeout(propOpenShow,2000,"asset.trainer.getPowerThree");
               if(NewHandGuideManager.Instance.mapID != 114)
               {
                  _gameInfo.selfGamePlayer.addEventListener("attackingChanged",__showThreeArrow);
               }
               else
               {
                  SocketManager.Instance.out.syncWeakStep(23);
                  SocketManager.Instance.out.syncWeakStep(25);
               }


            }
         }
         else
         {
            setRightPropVisible(false,1);
         }
         if(PlayerManager.Instance.Self.IsWeakGuildFinish(10))
         {
            if(!PlayerManager.Instance.Self.IsWeakGuildFinish(26))
            {
               if(NewHandGuideManager.Instance.mapID != 114)
               {
                  _gameInfo.selfGamePlayer.addEventListener("attackingChanged",__onDander);
                  _gameInfo.selfGamePlayer.addEventListener("danderChanged",__onDander);
               }
               else
               {
                  SocketManager.Instance.out.syncWeakStep(26);
               }

            }
         }
         if(PlayerManager.Instance.Self.IsWeakGuildFinish(11) && !PlayerManager.Instance.Self.IsWeakGuildFinish(50))
         {
            setTimeout(propOpenShow,2000,"asset.trainer.getPlane");
            SocketManager.Instance.out.syncWeakStep(50);
         }
         if(PlayerManager.Instance.Self.IsWeakGuildFinish(19) && !PlayerManager.Instance.Self.IsWeakGuildFinish(54))
         {
            if(PlayerManager.Instance.Self.FightBag.itemNumber != 0)
            {
               trace("");
            }
         }
         if(PlayerManager.Instance.Self.IsWeakGuildFinish(51))
         {
            if(!PlayerManager.Instance.Self.IsWeakGuildFinish(53))
            {
               setTimeout(propOpenShow,2000,"asset.trainer.getTwoTwenty");
               SocketManager.Instance.out.syncWeakStep(53);
            }
         }
         else
         {
            setRightPropVisible(false,0,6);
         }
         if(PlayerManager.Instance.Self.IsWeakGuildFinish(55))
         {
            if(!PlayerManager.Instance.Self.IsWeakGuildFinish(58))
            {
               setTimeout(propOpenShow,2000,"asset.trainer.getThreeFourFive");
               SocketManager.Instance.out.syncWeakStep(58);
            }
         }
         else
         {
            setRightPropVisible(false,3,4,5);
         }
      }

      // Completion is recorded when an eligible hint is first displayed, not when
      // subscribing. Keep turn-end cleanup even after a hint has been completed.
      private function __onDander(param1:LivingEvent) : void
      {
         if(_gameInfo.selfGamePlayer.isAttacking)
         {
            if(GameControl.Instance.Current.selfGamePlayer.dander >= 200 && !PlayerManager.Instance.Self.IsWeakGuildFinish(26))
            {
               NewHandContainer.Instance.showArrow(18,-30,"trainer.posTipPower");
               SocketManager.Instance.out.syncWeakStep(26);
            }
         }
         else
         {
            NewHandContainer.Instance.clearArrowByID(18);
         }
      }

      private function __showTenPersentArrow(param1:LivingEvent) : void
      {
         if(_gameInfo.selfGamePlayer.isAttacking)
         {
            if(!PlayerManager.Instance.Self.IsWeakGuildFinish(6))
            {
               NewHandContainer.Instance.showArrow(19,-90,"trainer.posTipTenPercent","","",null,2000);
               NewHandContainer.Instance.showArrow(20,-90,"trainer.posTipOne","asset.trainer.dungeonGuide10Txt","trainer.dungeonGuide10TxtPos",null,2000);
               SocketManager.Instance.out.syncWeakStep(6);
            }
         }
         else
         {
            NewHandContainer.Instance.clearArrowByID(19);
            NewHandContainer.Instance.clearArrowByID(20);
         }
      }

      private function __showThreeArrow(param1:LivingEvent) : void
      {
         if(_gameInfo.selfGamePlayer.isAttacking)
         {
            if(!PlayerManager.Instance.Self.IsWeakGuildFinish(23))
            {
               NewHandContainer.Instance.showArrow(21,-90,"trainer.posTipThree");
               SocketManager.Instance.out.syncWeakStep(23);
               SocketManager.Instance.out.syncWeakStep(25);
            }
         }
         else
         {
            NewHandContainer.Instance.clearArrowByID(21);
         }
      }
      private function propOpenShow(param1:String) : void
      {
         var _loc2_:MovieClipWrapper = new MovieClipWrapper(ClassUtils.CreatInstance(param1),true,true);
         LayerManager.Instance.addToLayer(_loc2_.movie,4,false);
      }

      protected function setWeaponPropVisible(param1:Boolean) : void
      {
         _weaponPropBar.setVisible(param1);
         if(param1)
         {
            if(!_weaponPropBar.parent)
            {
               addChild(_weaponPropBar);
            }
         }
         else if(_weaponPropBar.parent)
         {
            _weaponPropBar.parent.removeChild(_weaponPropBar);
         }
      }

      protected function setRightPropVisible(param1:Boolean, ... rest) : void
      {
         var _loc3_:int = 0;
         if(_rightPropBar)
         {
            _loc3_ = 0;
            while(_loc3_ < rest.length)
            {
               _rightPropBar.setPropVisible(rest[_loc3_],param1);
               _loc3_++;
            }
         }
      }

      protected function setSelfPropBarVisible(param1:Boolean) : void
      {
         if(_horseSkillBar)
         {
            if(param1)
            {
               _horseSkillBar.enter();
            }
            else
            {
               _horseSkillBar.leaving();
            }
         }
         if(_customPropBar)
         {
            _customPropBar.setVisible(param1);
            if(param1)
            {
               if(!_customPropBar.parent)
               {
                  addChild(_customPropBar);
               }
            }
            else if(_customPropBar.parent)
            {
               _customPropBar.parent.removeChild(_customPropBar);
            }
         }
      }

      protected function setArrowVisible(param1:Boolean) : void
      {
         _arrow.visible = param1;
      }

      public function setEnergyVisible(param1:Boolean) : void
      {
         _energy.visible = param1;
      }

      public function onUseEggKingHandler(param1:int, param2:Number, param3:Boolean) : void
      {
         if(_energy)
         {
            _energy.onUseEggKingHandler(param1,param2,param3);
         }
      }

      override public function dispose() : void
      {
         super.dispose();
         if(_gameInfo)
         {
            _gameInfo.selfGamePlayer.removeEventListener("attackingChanged",__onDander);
            _gameInfo.selfGamePlayer.removeEventListener("danderChanged",__onDander);
            _gameInfo.selfGamePlayer.removeEventListener("attackingChanged",__showThreeArrow);
            _gameInfo.selfGamePlayer.removeEventListener("attackingChanged",__showTenPersentArrow);
            _gameInfo = null;
         }
         if(_petSkillIsShowBtn)
         {
            _petSkillIsShowBtn.removeEventListener("click",__onPetSillIsShowBtnClick);
            _petSkillIsShowBtn.removeEventListener("rollOver",__onPetSillIsShowBtnOver);
            _petSkillIsShowBtn.removeEventListener("rollOut",__onPetSillIsShowBtnOut);
            _petSkillIsShowBtn.removeEventListener("mouseDown",__onPetSillIsShowBtnMousedown);
            ObjectUtils.disposeObject(_petSkillIsShowBtn);
            _petSkillIsShowBtn = null;
         }
         ObjectUtils.disposeObject(_arrow);
         _arrow = null;
         ObjectUtils.disposeObject(_energy);
         _energy = null;
         ObjectUtils.disposeObject(_customPropBar);
         _customPropBar = null;
         ObjectUtils.disposeObject(_insectProBar);
         _insectProBar = null;
         ObjectUtils.disposeObject(_horseSkillBar);
         _horseSkillBar = null;
         ObjectUtils.disposeObject(_weaponPropBar);
         _weaponPropBar = null;
         ObjectUtils.disposeObject(_tool);
         _tool = null;
         ObjectUtils.disposeObject(_petSkill);
         _petSkill = null;
         ObjectUtils.disposeObject(_rightPropBar);
         _rightPropBar = null;
         ObjectUtils.disposeObject(_bossPropBar);
         _bossPropBar = null;
         if(_petAvatarBar)
         {
            ObjectUtils.disposeObject(_petAvatarBar);
            _petAvatarBar = null;
         }
      }

      public function showPropBar() : void
      {
         if(_rightPropBar)
         {
            _rightPropBar.showPropBar();
         }
         if(_bossPropBar)
         {
            _bossPropBar.showPropBar();
         }
      }

      public function get rescuePropBar() : RescuePropBar
      {
         return _rescuePropBar;
      }

      public function get insectProBar() : InsectProBar
      {
         return _insectProBar;
      }

      public function get rightPropBar() : RightPropBar
      {
         return _rightPropBar;
      }

      public function get moviePropBar() : BossRightPropBar
      {
         return _bossPropBar;
      }

      public function get arrow() : ArrowView
      {
         return _arrow;
      }
   }
}
