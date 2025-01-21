# LED Status 

*Use USB connected LED sticks to show system status at a glance.*

## Color codes


    RED = SYSTEM DOWN
    Yellow = No internet connection
    White = Connected to internet, listening to ads-b messages
    Green = Receiving ads-b messages


## Supported hardware

* blink(1) by thingm - https://github.com/todbot/blink1
* blinkstick.com - 


## How it works

The USB led sticks are exposed in `/sys/class/leds`.


    root@f3454bc:~# ls -1 /sys/class/leds/    
    default-on
    led0
    led1
    mmc0
    mmc0::
    thingm0:blue:led0
    thingm0:blue:led1
    thingm0:green:led0
    thingm0:green:led1
    thingm0:red:led0
    thingm0:red:led1


We can write values to the different RGB colors, thus:

    root@f3454bc:~# echo 128 > /sys/class/leds/thingm0\:green\:led1/brightness 
    root@f3454bc:~# echo 128 > /sys/class/leds/thingm0\:blue\:led0/brightness 
    root@f3454bc:~# echo 128 > /sys/class/leds/thingm0\:red\:led0/brightness

## Dependencies 

blink(1) has support (built in the linux kernel)[https://github.com/todbot/blink1/blob/main/linux/README.md#linux-kernel-support]. The BlinkStick needs a (user daemon)[https://github.com/ktgeek/bluld] for the kernel to treat it as a LED in `/sys/class/leds`.

Make sure the USB LED is inserted during setup. The install script will check the type of connected hardware, and install if necessary.

### References

https://github.com/todbot/blink1/blob/main/docs/blink1-mk2-tricks.md#use-the-serverdown-to-turn-on-if-your-server-dies

