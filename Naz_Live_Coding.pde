// ——— libs
import ddf.minim.*;
import ddf.minim.analysis.*;

// ——— audio & fft
Minim minim;
AudioPlayer player;
FFT fft;
int iBassStart, iBassEnd, iTrebleStart, iTrebleEnd;

// ——— sayfalar / dünya
boolean worldMode = false;     // P: 2D <-> Dünya
boolean spinWorld = false;     // A: döndür
boolean dirLightOn = false;    // D: yönlü ışık
boolean spinLight  = false;    // F: ışığı döndür (basılıyken)
boolean pulseWorld = false;    // S: nefes büyü-küçül
float worldAngle = 0, lightAngle = 0, lightSpeed = 0.03, worldScale = 1;
PImage earthTex;
PShape globe;
boolean whiteBG = false;  // O: dünya sayfası arka planı beyaz
boolean showLineI = false;  // I: merkezde yatay beyaz şerit (arkada)
boolean showLinesM = false;  // M: merkez şeritten yukarı-aşağı incelen çizgiler

int   mStep = 0;     // şu an kaç çizgi görünsün (her frame artar)
float mGap  = 16;    // çizgiler arası dikey mesafe (px)

// ——— 2D kontroller
boolean hold1=false, hold2=false, hold3=false, hold4=false, hold5=false, hold6=false, hold7=false, hold8=false;

boolean holdL = false;   // L basılıyken mozaik
int lTiles = 20;         // her framede basılacak parça sayısı (yoğunluk)


// L mozaik için kalıcı parçalar
ArrayList<Patch> lPatches = new ArrayList<Patch>();
int lRate = 3;        // her 3. framede yeni parça üret (hız)
int lLife = 45;       // her parça ekranda 45 frame kalsın (~0.75 sn @60fps)


// K tüneli (kare prizma hissi)
boolean holdK = false;
int    kLayers = 40;     // aynı anda görünen kare sayısı
float  kGap    = 6;      // katmanlar arası gecikme (frame)
float  kSpeed  = 6;      // büyüme hızı (piksel / frame)
color  kNear   = color(255, 220, 180); // yakın renk
color  kFar    = color(80, 180, 255);  // uzak renk

float mx, my, ease = 0.2;      // sahte mouse
float step6 = 50; int diag6 = 0;    // 6: diagonal grid
float t7 = 0, speed7 = 0.02; int layers7 = 10;  // 7: tünel

void setup() {
  fullScreen(P3D);
  frameRate(60);
  noStroke();
  rectMode(CENTER);
  
  // kalite
  pixelDensity(displayDensity());
  smooth(8);
  strokeCap(ROUND); strokeJoin(ROUND);
  textureMode(NORMAL);
  hint(ENABLE_TEXTURE_MIPMAPS);
  sphereDetail(60);

  // ses
  minim = new Minim(this);
  player = minim.loadFile("ayva.mp3");
  player.loop();

  fft = new FFT(player.bufferSize(), player.sampleRate());
  iBassStart   = fft.freqToIndex(20);
  iBassEnd     = fft.freqToIndex(150);
  iTrebleStart = fft.freqToIndex(4000);
  iTrebleEnd   = fft.freqToIndex(8000);

  // dünya
  earthTex = loadImage("earth.jpg");          // 2:1 equirectangular JPG
  globe = createShape(SPHERE, min(width, height)*0.22);
  globe.setTexture(earthTex);
  globe.setStroke(false);

  mx = width/2; my = height/2;
}

void draw() {
  // —— FFT
  fft.forward(player.mix);
  float bass=avg(fft, iBassStart, iBassEnd);
  float treb=avg(fft, iTrebleStart, iTrebleEnd);
  bass = constrain(bass, 0, 12);
  treb = constrain(treb, 0, 12);

 if (worldMode) {

  // ——— Dünya sayfası (ÖNCE: arkadaki efektler ve prizma) ———
  background( whiteBG ? 255 : 0 );

  // K: merkezden büyüyen kare tüneli (ARKA PLAN)
  if (holdK) drawKTunnel();
  
if (showLineI) {
  pushMatrix();
  pushStyle();
  noLights();
  translate(width/2, height/2, -1);
  rectMode(CENTER);
  noStroke();
  fill(whiteBG ? 0 : 255);   // arkaplan beyazsa siyah, değilse beyaz
  rect(0, 0, width, 50);
  popStyle();
  popMatrix();
}
// M: merkez şeritten yukarı + aşağı doğru teker teker beliren çizgiler (ARKADA)
if (showLineI && showLinesM) {
  pushMatrix();
  pushStyle();
  noLights();
  translate(width/2, height/2, -1.1);           // şeridin biraz arkasında
  stroke(whiteBG ? 0 : 255);                    // arkaplana zıt renk

  // ekrana sığabilecek max çizgi sayısı (yarım ekran / aralık)
  int maxN = int((height * 0.5) / mGap);

  // animasyon: her frame bir çizgi daha eklensin (yavaşlatmak istersen %2-3 frame)
  // if (frameCount % 2 != 0) { /* yavaşlatma */ }  // istersen aç
  mStep++;
  if (mStep > maxN) mStep = 0;                   // sayfa bitti → başa sar

  // kalınlık uzakla incelsin
  for (int k = 1; k <= mStep; k++) {
    float y  =  k * mGap;                        // aşağı
    float y2 = -k * mGap;                        // yukarı
    float sw = max(1, 10 - k * 0.45);            // incelme
    strokeWeight(sw);
    line(-width/2, y,  width/2, y);
    line(-width/2, y2, width/2, y2);
  }

  popStyle();
  popMatrix();
}



  // ——— ŞİMDİ: ışıkları aç ve dünyayı önde çiz ———
  ambientLight(40, 40, 60);
  lights(); // temel ışık
  if (dirLightOn) {
    if (spinLight) lightAngle += lightSpeed;
    directionalLight(255,255,255, cos(lightAngle), -0.25, sin(lightAngle));
  }

  // nefes ölçek (S)
  worldScale = pulseWorld ? 1.0 + map(bass + treb, 0, 24, 0, 0.25) : 1.0;

  // Dünya (Z=0'da → prizmadan önde)
  pushMatrix();
  translate(width/2, height/2, 0);
  if (spinWorld) worldAngle += 0.01;
  rotateY(worldAngle);
  scale(worldScale);
  shape(globe);
  popMatrix();

  // L: mozaik — DÜNYA dönmüyorken, ekran merkezinde ve ÖNDE
  if (holdL && !spinWorld) drawLMosaic();

  return;
}


  // ——— 2D sayfa (trail)
  hint(DISABLE_DEPTH_TEST);
  noStroke();
  rectMode(CORNER);
  fill(0, 20);                 // iz silme hızı (20–40 arası oyna)
  rect(0, 0, width, height);
  rectMode(CENTER);
  hint(ENABLE_DEPTH_TEST);
  
   float radius = min(width, height) * 0.15;
  float targetX = width/2  + map(bass, 0, 12, -radius, radius);
  float targetY = height/2 + map(treb, 0, 12,  radius, -radius);
  mx = lerp(mx, targetX, ease);
  my = lerp(my, targetY, ease);



  // anlık noktalar/kareler
  float r = random(8, 24) + map(bass, 0, 12, 0, 18);
  float x = random(mx - 25, mx + 25);
  float y = random(my - 25, my + 25);
  float S = r * 5;
  float a = constrain(random(-2*x, 2*x), S/2, width  - S/2);
  float b = constrain(random(-2*y, 2*y), S/2, height - S/2);
  color c = hold1 ? color(255) : color(random(255), random(255), random(255));


  // ——— çizgi/çerçeve geçişi (depth açık)
  if (hold2) { noFill(); stroke(255); rect(x, y, r, r); }
  if (hold3) { noFill(); stroke(255); rect(a, b, S, S); }
  if (hold2 && hold3) {
    float sx1=x-r/2, sy1=y-r/2, sx2=x+r/2, sy2=y-r/2, sx3=x+r/2, sy3=y+r/2, sx4=x-r/2, sy4=y+r/2;
    float bx1=a-S/2, by1=b-S/2, bx2=a+S/2, by2=b-S/2, bx3=a+S/2, by3=b+S/2, bx4=a-S/2, by4=b+S/2;
    noFill(); stroke(255);
    line(sx1,sy1,bx1,by1); line(sx2,sy2,bx2,by2); line(sx3,sy3,bx3,by3); line(sx4,sy4,bx4,by4);
  }

  // 6: diagonal grid (çerçeve görünümü)
  if (hold6) {
    noFill(); stroke(255, 140);
    for (int i=0;i<=diag6;i++) {
      int j = diag6 - i;
      float x6=i*step6, y6=j*step6;
      if (x6<width && y6<height) rect(x6, y6, step6, step6);
    }
    diag6++;
    int maxI=int(width/step6)-1, maxJ=int(height/step6)-1;
    if (diag6 > maxI+maxJ) diag6=0;
  }

  // 7: merkezden hedefe tünel (çerçeve)
  if (hold7) {
    float cx=width/2.0, cy=height/2.0;
    noFill(); stroke(255);
    for (int i=0;i<layers7;i++) {
      float u=(t7+i*0.10)%1.0;
   //   rect(lerp(cx,x,u), lerp(cy,y,u), lerp(r*0.2,r,u), lerp(r*0.2,r,u));
      rect(lerp(cx,a,u), lerp(cy,b,u), lerp(S*0.2,S,u), lerp(S*0.2,S,u));
    }
    t7 += speed7; if (t7>=1) t7-=1;
  }

  if (hold8) background(random(255), random(255), random(255));  // hızlı renk flaşı

  // ——— UNIVERSAL OVERLAY (en üstte doldur + daire)
  hint(DISABLE_DEPTH_TEST);         // z-test kapalı → üstte
  blendMode(BLEND);
  noStroke();
  if (hold4) {
  fill(c, 230);
  if (!hold5 && !hold7) rect(x, y, r, r);  // 7 açıkken küçük dolgu yok
  rect(a, b, S, S);                        // büyük dolgu çiz
}
    if (!hold5) rect(x, y, r, r);   // 5'te küçük kareyi atla (sadece çerçeve)
    rect(a, b, S, S);
  
if (!hold5 && !hold6 && !hold7 && !hold8) {  // 5/6/7 aktifken daire yok                    // daire (5 modunda istemiyoruz)
    fill(c, 220);
    ellipse(x, y, r, r);
  }
  hint(ENABLE_DEPTH_TEST);
}

// ——— yardımcı
float avg(FFT f, int s, int e) {
  float sum=0; int n=0;
  for (int i=s;i<=e;i++){ sum+=f.getBand(i); n++; }
  return n>0? sum/n : 0;
}

void drawKTunnel() {
  // Merkezden dışa büyüyen ama döngüyle başa saran kare tüneli
  pushStyle();
  rectMode(CENTER);
  noFill();
  colorMode(HSB, 360, 100, 100, 255);

  float cx = width * 0.5;
  float cy = height * 0.5;

  int   layers = 40;     // görünen katman sayısı
  float gap    = 6;      // katmanlar arası gecikme (frame)
  float speed  = 6;      // px/frame büyüme


  // Ekranın köşeye kadar olan en büyük mesafesi (biraz payla)
  float maxS = sqrt(width*width + height*height) * 1.1;
  float cycleFrames = maxS / speed;   // bu kadar frameden sonra başa sar

  for (int i = 0; i < layers; i++) {
    // Pozitif mod: yaş döngü içinde 0..cycleFrames
    float rawAge = frameCount - i * gap;
    float age = (rawAge % cycleFrames + cycleFrames) % cycleFrames;

    float s = age * speed;            // kenar uzunluğu 0..maxS
    float u = s / maxS;               // 0 uzak → 1 yakın (parlaklık/kalınlık)

    // Renk: uzak koyu, yakın parlak; hafif ton kayması
    float hue = (frameCount*2 + i*10) % 360;
    float sat = 80;
    float bri = lerp(25, 100, u);     // asla 0 değil → görünür
    float alp = lerp(120, 220, u);    // yakına doğru daha opak

    stroke(color(hue, sat, bri, alp));
    strokeWeight(1 + 2*u);

    // hafif dikey sıkıştırma → derinlik
    pushMatrix();
    translate(cx, cy);
    scale(1.0, 0.75 + 0.25*u);
    rect(0, 0, s, s);
    popMatrix();
  }

  popStyle();
}

void drawLMosaic() {
  // ekran uzayı, dünyanın ÖNÜNDE
  hint(DISABLE_DEPTH_TEST);
  pushStyle();
  imageMode(CENTER);

  float cx = width * 0.5;
  float cy = height * 0.5;
  float spread = min(width, height) * 0.12;

  // — yeni parçaları seyrek ekle (yanıp sönme azalır)
  if (frameCount % lRate == 0) {
    int spawn = 6;                        // her seferde kaç tane eklenecek
    for (int i = 0; i < spawn; i++) {
      int sw = int(random(60, 440));
      int sh = int(random(60, 440));
      int sx = int(random(0, max(1, earthTex.width  - sw)));
      int sy = int(random(0, max(1, earthTex.height - sh)));
      PImage piece = earthTex.get(sx, sy, sw, sh);

      float dx = cx + random(-spread, spread);
      float dy = cy + random(-spread, spread);
      float k = random(0.75, 1.25);

      lPatches.add(new Patch(piece, dx, dy, sw*k, sh*k));
    }
  }

  // — tüm yaşayan parçaları çiz
  for (int i = lPatches.size()-1; i >= 0; i--) {
    Patch p = lPatches.get(i);
    if (p.isDead(lLife)) {
      lPatches.remove(i);
    } else {
      p.draw(); // opak, orijinal renk
    }
  }

  popStyle();
  hint(ENABLE_DEPTH_TEST);
}


// ——— klavye
void keyPressed() {
  if (key=='1') hold2=true;
  if (key=='2') hold2=true;
  if (key=='3') hold3=true;
  if (key=='4') hold4=true;
  if (key=='5') hold5=true;
  if (key=='6') hold6=true;
  if (key=='7') hold7=true;
  if (key=='8') hold8=true;

 // if (key=='A'||key=='a') spinWorld = true;
  if (key=='D'||key=='d') dirLightOn = !dirLightOn;
  if (key=='F'||key=='f') spinLight = true;
  if (key=='S'||key=='s') pulseWorld = !pulseWorld;
  if (key=='L' || key=='l') holdL = true;
}
void keyReleased() {
  if (key=='1') hold2=false;
  if (key=='2') hold2=false;
  if (key=='3') hold3=false;
  if (key=='4') hold4=false;
  if (key=='5') hold5=false;
  if (key=='6') hold6=false;
  if (key=='7') hold7=false;
  if (key=='8') hold8=false;

  if (key=='F'||key=='f') spinLight = false;
  if (key=='P'||key=='p') worldMode = !worldMode;  // P: sayfa değiştir (debounce)
  if (key=='K' || key=='k') holdK = !holdK;   // aç/kapa
  if (key=='L' || key=='l') holdL = false;
  if (key=='A' || key=='a') spinWorld = !spinWorld; 
if (key=='O' || key=='o') whiteBG = !whiteBG;
if (key=='I' || key=='i') showLineI = !showLineI;
if (key=='M' || key=='m') showLinesM = !showLinesM;



}

class Patch {
  PImage img;
  float x, y, w, h;
  int born;           // doğduğu frame

  Patch(PImage img, float x, float y, float w, float h) {
    this.img = img; this.x = x; this.y = y; this.w = w; this.h = h;
    this.born = frameCount;
  }

  boolean isDead(int life) { return frameCount - born > life; }

  void draw() {
    // opak ve orijinal renk (noTint)
    noTint();
    image(img, x, y, w, h);
  }
}
