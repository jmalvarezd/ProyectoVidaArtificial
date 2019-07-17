
public class Piel {

    float[][][] space;
    float[][][] newSpace;
    float dA = 1f;
    float dB = 0.5f;
    float f = 0.055f;
    float k = 0.062f;
    PImage img;
    boolean c = false;
    boolean ready = false;
    
    /*
    float dA = 1.05f;
    float dB = 0.5f;
    float f = 0.055f;
    float k = 0.062f;
    */
    
    /*
    float dA = 1.1f;
    float dB = 0.5f;
    float f = 0.055f;
    float k = 0.062f;
    */
    
    
    int w = 100;
    int h = 100;    
    
    void setup() {
        space = new float[w][h][2];
        newSpace = new float[w][h][2];

        for (int i = 0; i < w; i++) {
            for (int j = 0; j < h; j++) {
                float a = 1;
                float b = 0;
                space[i][j][0] = a;
                space[i][j][1] = b;
                newSpace[i][j][0] = a;
                newSpace[i][j][1] = b;
            }
        }
        
        for (int n = 0; n < 50; n++) {
            int startx = (int) (Math.random()* (w) -1);
            int starty = (int) (Math.random() * (h) -1);

            for (int i = startx; i < startx + 10 && i < w; i++) {
                for (int j = starty; j < starty + 10 && j < h; j++) {
                    float a = 1;
                    float b = 1;
                    space[i][j][0] = a;
                    space[i][j][1] = b;
                    newSpace[i][j][0] = a;
                    newSpace[i][j][1] = b;
                }
            }
        }
        update();
        toImg();
    }

    void update() {
        for (int s = 0; s < 100; s++) {
            for (int i = 1; i < w - 1; i++) {
                for (int j = 1; j < h - 1; j++) {

                    float a = space[i][j][0];
                    float b = space[i][j][1];

                    float laplaceA = 0;
                    laplaceA += a * -1;                
                    laplaceA += space[i + 1][j    ][0] * 0.2;
                    laplaceA += space[i - 1][j    ][0] * 0.2;
                    laplaceA += space[i    ][j + 1][0] * 0.2;
                    laplaceA += space[i    ][j - 1][0] * 0.2;
                    laplaceA += space[i - 1][j - 1][0] * 0.05;
                    laplaceA += space[i + 1][j - 1][0] * 0.05;
                    laplaceA += space[i - 1][j + 1][0] * 0.05;
                    laplaceA += space[i + 1][j + 1][0] * 0.05;

                    float laplaceB = 0;
                    laplaceB += b * -1;
                    laplaceB += space[i + 1][j    ][1] * 0.2;
                    laplaceB += space[i - 1][j    ][1] * 0.2;
                    laplaceB += space[i    ][j + 1][1] * 0.2;
                    laplaceB += space[i    ][j - 1][1] * 0.2;
                    laplaceB += space[i - 1][j - 1][1] * 0.05;
                    laplaceB += space[i + 1][j - 1][1] * 0.05;
                    laplaceB += space[i - 1][j + 1][1] * 0.05;
                    laplaceB += space[i + 1][j + 1][1] * 0.05;

                    float newA = a + (dA * laplaceA - a * b * b + f * (1 - a)) * 1;
                    float newB = b + (dB * laplaceB + a * b * b - (k + f) * b) * 1;

                    //newSpace[i][j][0] = constrain(newSpace[i][j][0], 0, 1);
                    //newSpace[i][j][1] = constrain([1], 0, 1);
                    newSpace[i][j][0] = newA > 1?1:newA;
                    newSpace[i][j][1] = newB > 1?1:newB;

                }
            }
            space = newSpace.clone();
        }
        ready = true;    
    }
    
    PImage toImg(){
        img = new PImage(w, h);
        for (int i = 0; i < w; i++) {
            for (int j = 0; j < h; j++) {
                float a = space[i][j][0];
                float b = space[i][j][1];
                if(this.c){
                  img.pixels[i + j * w] = color((a - b) * 255,0,0);
                }else{
                  img.pixels[i + j * w] = color(0,0,(a - b) * 255);
                }
                
            }
        }
        img.updatePixels();
        return img;
    }
}
