<hr />
This website is entirely open source and can be found [here](https://github.com/chirprush/shareable-wearables).

## Introduction
Hello and welcome to the Shareable Wearables team! Shareable Wearables™ is all about two major principles: *usability* and *accessibility*. Devices for users should be intuitive and should not make someone have to guess at how it works. In addition, we want to make a device that helps others, especially those with disabilities, to go about their everyday lives. This year, 2022, our group is made up of five participants and three advisors.

The participants:

- Aarav Surapaneni
- Arnav Patel
- Rushil Kakkad
- Rushil Surti <small>(hey that's me!)</small>
- Abdulaziz Abdusamatov 

The advisors:

- [Christopher Choy](https://chrischoy.net/)
- Lily Klucinec
- Jingyuan Fang

![That's <small>*(some of)*</small> us!](media/team.png)

## Our Start

For our first workshop, we focused on researching and understanding what exactly usability is. Usability is all about the intuitiveness of a device and the different functions it provides. A cup with a handle is a good example of something that is usable as there is little room for error or confusion when using it, and it can provide many functions other than just liquid storage. We analyzed some real life examples of everyday devices and labeled them as either usable or not usable. Some examples of these were public bathrooms, which we thought were very unintuitive with their open ceilings and floor windows, lack of ventilation, and incompetent locks. Another bad example of usability would be some push-pull doors that are vague in which direction to push or pull.

Moving onto our next session, we tackled the problem of accessibility. In doing this, we researched different disabilities, how they affect the daily lives of people, and what problems could be solved with technology. We looked at a couple of categories of disabilities like those impairing the movements of individuals, some that affected the learning or development process, as well as those that affected the senses, like deafness, blindness, and others. As a group, we all sort of had our own opinions on which problem we wanted to tackle, but we eventually stumbled upon a nice medium of our ideas.

For our project, we decided that we wanted to build something to aid those with a condition called sensory overload. Sensory overload is a condition affecting those with ADHD and other similar disabilities that makes them hypersensitive to certain senses. Large noises, bright flashes of light, and uncomfortable textures are just but a few of the conditions that can cause a trigger or lead to seizures. Making something that could detect these conditions and alert the user could provide some benefit in aiding their condition. At this time, though, we still could not decide on exactly what sort of device or accessory this shareable wearable would be.

Following that, we mainly talked about the tooling that we were going to use for our project and how we could actually turn ideas into something physical. For the modeling of the glasses, we used a 3D modeling program called [Maya](https://www.autodesk.com/products/maya/overview). This would be used to create our glasses, which we would then give to a 3D printer to actually create the physical item. For any functionality or work, we would attach an [Arduino UNO](http://store-usa.arduino.cc/products/arduino-uno-rev3) device combined with sensors that could run any code that we give it. This would be useful in detecting sensory data like light or sound levels and being to do something with it.

## Planning and Modeling
After a few sessions, we finally got to work in-person on our project. There, all five of us took a vote on some of our proposed device forms. We had ideas ranging from bracelets and necklaces to masks and glasses. In the end, we finally decided on the concept of glasses that alert the user of dangerous, potentially triggering situations. This would be determined by taking a sound value and light value and testing whether they are over a certain threshold. Then we could turn on a buzzer to alert the user. We also wanted to add a component that would block some of these overloaded senses, but the overall complexity of the problem seemed a bit high and we could't find a provider for one of our ideas ([electrochromic glass](https://en.wikipedia.org/wiki/Electrochromism)), so we pushed it to something that we would do if we had more time. This day, we also got to look at some of the Arduino equipment that we would be using. We built some basic test programs to try the sensors out. One of the example programs that we made can be found here. This program can blink an LED at a specific speed correlating to how close an object is to the board.

```cpp
constexpr int pingPin =  7;
constexpr int echoPin =  6;
constexpr int ledPin  = 13;

long microsecondsToInches(long mcs) {
	return mcs / 148;
}

void setup() {
	Serial.begin(9600);
	pinMode(pingPin, OUTPUT);
	pinMode(echoPin, INPUT);
	pinMode(ledPin,  OUTPUT);
}

void loop() {
	digitalWrite(pingPin, LOW);
	delayMicroseconds(2);

	digitalWrite(pingPin, HIGH);
	delayMicroseconds(10);

	digitalWrite(pingPin, LOW);

	long duration = pulseIn(echoPin, HIGH);
	long inches = microsecondsToInches(duration);

	Serial.print(inches);
	Serial.println("in");

	if (inches < 100) {
		digitalWrite(ledPin, HIGH);
		delay(inches * 10);
	}

	digitalWrite(ledPin, LOW);
	delay(100);
}
```

Nearing the midpoint for our project schedule, we started working on the modeling for the glasses, going through several iterations and even using measurements of real-life glasses to model them accurately. We also had to think of where we were going to store both the sound and light sensors as well as the Arduino device.

![Our first design](media/first.png)

![Our rough finished product](media/final.png)

In the end, we planned to attach the Arduino somewhere around the back of the head, putting the sound sensor and buzzer near the right ear and the light sensor near the front. Furthermore, we decided that we would thread the wiring through rectangular tubes attached on the front and right side of the glasses. After finishing it, we then had to disassemble the model into separate parts to ready it for 3D printing.

![A disassembled look at the glasses](media/disassembled.png)

Overall, the modeling and especially the 3D printing stage took quite some time to get everything right. Along the way, we had quite the couple of mishaps, but the process was really informative and fun!

![(whoops!)](media/whoops.png)

## The Finish Line

The second to last step after modeling was the coding of the interaction between the sensors. The basic function of the glasses is to take in readings from both the light and sound sensors, determine if these readings are at unsuitable levels for the user, and alert the user by turning on a buzzer. This may or may not come as a surprise, but I felt that the overall programming part was one of the more simpler portions of our project.

```cpp
// We want to have both a light sensor and sound sensor to read values
// and, when any one of the values are above a certain threshold, we
// will turn on a buzzer sensor. We may also want an off button.

class LightSensor {
public:
  LightSensor(int _pin) : pin(_pin) {
    pinMode(_pin, INPUT);
  }

  int read() {
    return analogRead(this->pin);
  }

private:
  int pin;
};

class SoundSensor {
public:
  SoundSensor(int _pin) : pin(_pin) {
    pinMode(_pin, INPUT);
  }

  int read() {
    return analogRead(this->pin);
  }

private:
  int pin;
};

class Buzzer {
public:
  static constexpr int runtime = 400;
  static constexpr int between_delay = 250;

  Buzzer(int _pin) : pin(_pin), time(0), beeps(0), frequency(0) {
    pinMode(_pin, OUTPUT);
  }

  void log() {
    Serial.print("(pin, state, time, beeps)");
    Serial.print(this->pin);
    Serial.print(", ");
    Serial.print((int)this->state);
    Serial.print(", ");
    Serial.print(this->time);
    Serial.print(", ");
    Serial.println(this->beeps);
  }

  void update(int t) {
    if (this->state == State::Waiting) {
      this->time = 0;
      this->off();
      this->beeps = 0;
      return;
    } else if (this->state == State::Between) {
      noTone(this->pin);
      this->time -= t;
      if (this->time <= 0) {
        tone(this->pin, this->frequency);
        this->time = runtime;
        this->state = State::Buzzing;
      }
      return;
    }
    this->time -= t;
    if (this->time <= 0) {
      this->beeps--;
      this->time = 0;
      this->off();
      if (this->beeps <= 0) {
        this->beeps = 0;
        this->state = State::Waiting;
      } else {
        this->time = between_delay;
        this->state = State::Between;
      }
    }
  }

  void on(int _beeps, int _frequency) {
    tone(this->pin, _frequency);
    this->beeps = _beeps;
    this->frequency = _frequency;
    this->state = State::Buzzing;
    this->time = runtime;
  }

  void off() {
    noTone(this->pin);
  }

  enum class State {
    Waiting,
    Between,
    Buzzing,
  };

private:
  int pin;
  State state { State::Waiting };
  int time;
  int beeps;
  int frequency;
};

enum class ReadingStatus {
  None,
  Light,
  Sound
};

struct Reading {
  static constexpr int LIGHT_THRESHOLD = 740;
  static constexpr int VOLUME_THRESHOLD = 940;

  Reading(int _li, int _v) : light_intensity(_li), volume(_v) {}


  void log() {
    Serial.print("(light, sound): ");
    Serial.print(this->light_intensity);
    Serial.print(", ");
    Serial.println(this->volume);
  }

  ReadingStatus status() {
    if (this->light_intensity >= LIGHT_THRESHOLD) {
      return ReadingStatus::Light;
    } else if (this->volume >= VOLUME_THRESHOLD) {
      return ReadingStatus::Sound;
    }
    return ReadingStatus::None;
  }

  int light_intensity;
  int volume;
};

class State {
public:
  State() {}

  Reading read() {
    return (Reading) {
      this->light_sensor.read(),
        this->sound_sensor.read(),
    };
  }

  void log_buzzer() {
    this->buzzer.log();
  }

  void buzz(int beeps, int frequency) {
    this->buzzer.on(beeps, frequency);
  }

  void wait(int ms) {
    delay(ms);
    // The buzzer update must be after we wait the actual amount
    // of time.
    this->buzzer.update(ms);
  }

private:
  LightSensor light_sensor { A0 };
  SoundSensor sound_sensor { A1 };
  Buzzer buzzer { A2 };
};

State state;

void setup() {
  Serial.begin(9600);
}

void loop() {
  auto reading = state.read();
  reading.log();
  auto status = reading.status();
  if (status == ReadingStatus::Light) {
    state.buzz(2, 500);
  } else if (status == ReadingStatus::Sound) {
    state.buzz(2, 65);
  }
  // state.log_buzzer();
  state.wait(50);
}
```

That brings us to where we are right now. After the 10th workshop session, everyone is working on our presentation material, including me at the moment writing this website. We'll only really have less than two weeks before the final presentation to assemble everything and iron out any potential bugs.

## Future Work/More Time
We don't really think that we'll continue developing this project much after the final presentation, but these are a few points in case any of us decide to return to it or if you, the reader, would like to try building something like this as well.

- Firstly, as mentioned previously, we wanted to try out the idea of blocking some of the overloaded senses. This would require some research into electrochromic glass (and how to actually even acquire some) as well as maybe wireless earbuds.
- Next, we could have possibly tackled more senses. How would we combat something like smell or touch sensory overload? This could facilitate the need for other sensors like air quality and such.
- Building on the previous point a little, there could be some better ways to tackle the senses as well in the form of more accurate testing. Unfortunately, with the time we had, we didn't get to research some of the more fine details on what levels actually trigger sensory overload. As well, the sound sensor could have measured over a longer period of time to find the frequency or the length of the loud noise. This would give a more accurate reading of whether the environment is unsuitable. This would probably entail storing a buffer of past reads and times as well as recording the rising edge of the wave for the frequency.

## Conclusion
We certainly had some problems along the way, and we also could have used a little more time to refine our thoughts and designs, but all in all, this was a really great learning experience. I would recommend anyone interested to definitely try Project Ignite out. The teammates and the advisors you get to meet are great and there is a wide selection of interests for almost everyone. There's even free food sometimes! I would, without a doubt, say that this is one of the more enjoyable extracurricular workshops I've participated in, and I'm truly glad I decided to sign up for it.

With that, I have to sign off. I hope you enjoyed this recap of our learning process, and I hope you'll enjoy the other projects as well. Bye!
