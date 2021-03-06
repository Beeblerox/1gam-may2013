package com.happyshiny.duel.entities;

import com.happyshiny.duel.entities.ChargeEmitter;
import com.happyshiny.util.SoundManager;
import nme.Lib;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxU;
import org.flixel.tweens.util.Ease;

class Player extends FlxSprite
{
    public var side : Int;
    public var energy : Float;
    public var slots : Array<ChargeEmitter>;

    public static var MAX_FINGERS : Int = 3;
    public static var SIDE_BOTTOM : Int = 1;
    public static var SIDE_TOP : Int = 2;
    public static var COLOR_TOP : Int = 0xffcc9900;
    public static var COLOR_BOTTOM : Int = 0xff0099cc;
    public static var HEIGHT : Int = 100;

    public function new(side : Int)
    {
        super(0, 0);

        slots = new Array<ChargeEmitter>();

        this.energy = 0;
        this.side = side;

        x = 0;
        if (side == Player.SIDE_TOP)
        {
            color = COLOR_TOP;
            makeGraphic(FlxG.width, Std.int(FlxG.height/2), 0xffffffff);
            y = 0;
            FlxG.tween(this, { y: HEIGHT - this.height }, 1.0, { ease: Ease.backOut });
        }
        else
        {
            color = COLOR_BOTTOM;
            makeGraphic(FlxG.width, Std.int(FlxG.height/2), 0xffffffff);
            y = FlxG.height - this.height;
            FlxG.tween(this, { y: FlxG.height - HEIGHT }, 1.0, { ease: Ease.backOut });
        }
    }

    public override function update()
    {
        super.update();

        if (this.y + this.height < 0 || this.y > FlxG.height)
        {
            kill();
            G.gameOver();
        }
    }

    public override function hurt(damage : Float)
    {
        if (!this.alive) return;

        super.hurt(damage);
        SoundManager.play("hit");

        FlxG.shake(0.01, 0.3);

        if (this.side == SIDE_TOP)
        {
            y = y - 11;
        }
        else
        {
            y = y + 11;
        }
    }

    public function charge(points : Array<FlxPoint>)
    {
        if (!this.alive) return;

        for(m in slots)
        {
            m.assigned = false;
        }

        var emittersActive = 0;
        for(p in points)
        {
            // Assign the closest ChargeEmitter to each touch
            var distance = Lib.MAX_FLOAT_VALUE;
            var closest : ChargeEmitter = null;
            for(m in slots)
            {
                if (m.assigned) continue;
                var d = FlxU.getDistance(p, new FlxPoint(m.x, m.y));
                if (d < distance)
                {
                    distance = d;
                    closest = m;
                }
            }
            if (closest == null)
            {
                closest = cast(G.emitters.recycle(ChargeEmitter), ChargeEmitter);
                closest.revive();
                closest.go();
                slots.push(closest);
            }
            closest.x = p.x;
            closest.y = p.y;
            closest.color = color;
            closest.assigned = true;

            emittersActive++;
            if (emittersActive >= MAX_FINGERS) break;
        }

        for (m in slots)
        {
            if (!m.assigned)
            {
                if (m.energy == ChargeEmitter.MAX_ENERGY)
                {
                    fire(new FlxPoint(m.x, m.y));
                }
                m.stop();
                slots.remove(m);
            }
        }
    }

    public function fire(p : FlxPoint)
    {
        if (!this.alive) return;

        var m : Missile = null;
        if (side == Player.SIDE_TOP)
        {
            m = cast(G.topGroup.recycle(Missile), Missile);
        }
        else
        {
            m = cast(G.bottomGroup.recycle(Missile), Missile);
        }

        m.player = this;
        m.x = p.x - Missile.WIDTH/2;
        m.revive();
    }
}
