# **Saxophone Hero**

## **Overview**

Step onto the stage with Saxophone Hero, where your tenor saxophone is the key to unlocking a rhythmic adventure through a world of sheet music. In this game, your character dashes through levels, scoring points by hitting the right notes. As the melodies flow from your tenor saxophone, so does your character, responding to each correctly played tone with precision and grace. The goal is simple yet captivating: play flawlessly to score high and rise through the ranks of this musical odyssey. Powered by machine learning, the game captures the pitch from your saxophone and translates it to player movement in real time. Whether you're just starting out with "Hot Cross Buns" or feeling nostalgic and want to play Frank Sinatra's "Fly Me To The Moon," Saxophone Hero promises to be an engaging fusion of music performance and interactive play, offering two levels that have varying difficulties.

## **Game Set-Up**

As long as you have a valid Apple Developer account and a MacBook Pro, this app will work automatically, as all necessary utilities for audio processing via Novocaine and game creation via SpriteKit are included in the repository. A Jupyter Notebook is included to visualize the training process, and a Python script for converting the PyTorch Mel Spectrogram Convolutional Neural Network (CNN) to an Apple CoreML is included. We decided to pursue this route instead of connecting the model to a server or setting up a serverless function, because the CoreML model will leverage the iPhone's GPU to accelerate Mel Spectrogram preprocessing and CNN runtime execution in the audio pitch detection task.

## **YouTube Demos**

### **Fly Me to The Moon Level Demo**

This video below includes a recorded demo by Reece of the Fly Me To The Moon level.

[![Fly Me to the Moon](gameplay.png)](https://www.youtube.com/watch?v=B8kT6JnvB68&list=PLx2oopIYb-6FwcKfDmZyXA88GNY_I2Oo3)

### **Note-Playing Capabilities Demo**

This video below includes a recorded demo by Reece playing down from a low F up to a high C on the tenor saxophone. We showcase the player movement and how it corresponds with each change in pitch.

[![12-Notes](level-selection.png)](https://www.youtube.com/watch?v=CLuUt8QcZaE&list=PLx2oopIYb-6FwcKfDmZyXA88GNY_I2Oo3&index=2)

### **User Interface Demo**

This video includes a recorded demo of us going through the User Interface through a screen recording on an iPhone. 

[![UI](home.png)]([https://www.youtube.com/watch?v=CLuUt8QcZaE&list=PLx2oopIYb-6FwcKfDmZyXA88GNY_I2Oo3&index=2](https://www.youtube.com/watch?v=2kmc06zytTs&list=PLx2oopIYb-6FwcKfDmZyXA88GNY_I2Oo3&index=3)https://www.youtube.com/watch?v=2kmc06zytTs&list=PLx2oopIYb-6FwcKfDmZyXA88GNY_I2Oo3&index=3)



