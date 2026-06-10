# Algorithmic Art Skill

---
title: "Algorithmic Art"
version: "3.0"
last_updated: "2026-01-07"
tags: [generative, art, p5js, rendering]
domains: [creative]
level: intermediate
estimated_time: "45min"
prerequisites: []
sources:
  - "p5.js Reference"
  - "Generative Art Patterns"
enforcement: recommended
tad_gates: []
---

> 来源: anthropics/skills 官方仓库，已适配 TAD 框架

## TL;DR Quick Checklist

```
1. [ ] 固定随机种子（可复现）
2. [ ] 参数化渲染（尺寸/颜色/步长等）
3. [ ] 导出多格式（PNG/GIF/SVG）与批处理脚本
4. [ ] 输出画廊与最佳样例；记录配置
5. [ ] 版权与许可标注
```

**Red Flags:** 不可复现、参数散落、未记录配置、输出单一格式

## 触发条件

当用户需要创建生成艺术、程序化图形、数学可视化或创意编码项目时，自动应用此 Skill。

---

## 核心能力

```
生成艺术工具箱
├── 基础技术
│   ├── 噪声算法
│   ├── 粒子系统
│   └── 分形几何
├── 视觉模式
│   ├── 对称图案
│   ├── 流场
│   └── 细胞自动机
├── 动态效果
│   ├── 动画循环
│   ├── 交互响应
│   └── 音频可视化
└── 输出格式
    ├── 静态图像
    ├── GIF 动画
    └── 实时画布
```

---

## p5.js 快速入门

### 基础模板

```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.9.0/p5.min.js"></script>
</head>
<body>
  <script>
    function setup() {
      createCanvas(800, 800);
      background(20);
    }

    function draw() {
      // 每帧绘制的内容
    }
  </script>
</body>
</html>
```

### 核心函数

```javascript
// 设置
function setup() {
  createCanvas(800, 800);      // 创建画布
  pixelDensity(2);             // 高清屏支持
  frameRate(60);               // 帧率
  noLoop();                    // 静态图像时使用
}

// 绘制循环
function draw() {
  background(20);              // 清除背景
  // 绘制代码...
}

// 交互事件
function mousePressed() {}
function keyPressed() {}
function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
}
```

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type   | Description            | Location                                |
|-----------------|------------------------|-----------------------------------------|
| `render_params` | 渲染参数与配置         | `.tad/evidence/art/params.md`           |
| `output_gallery`| 输出画廊（样例图）     | `.tad/evidence/art/gallery/`            |

### Acceptance Criteria

```
[ ] 作品可复现（固定种子+参数记录）
[ ] 输出质量、尺寸与格式满足需求
```

### Artifacts

| Artifact      | Path                              |
|---------------|-----------------------------------|
| Params        | `.tad/evidence/art/params.md`     |
| Gallery       | `.tad/evidence/art/gallery/`      |

## 噪声与随机

### Perlin 噪声

```javascript
function setup() {
  createCanvas(800, 800);
  noLoop();
}

function draw() {
  background(20);

  // 噪声参数
  let noiseScale = 0.01;

  // 绘制噪声场
  loadPixels();
  for (let x = 0; x < width; x++) {
    for (let y = 0; y < height; y++) {
      let noiseVal = noise(x * noiseScale, y * noiseScale);
      let brightness = noiseVal * 255;

      let index = (x + y * width) * 4;
      pixels[index] = brightness;
      pixels[index + 1] = brightness;
      pixels[index + 2] = brightness;
      pixels[index + 3] = 255;
    }
  }
  updatePixels();
}
```

### 随机行走

```javascript
let walker;

function setup() {
  createCanvas(800, 800);
  background(20);
  walker = { x: width / 2, y: height / 2 };
}

function draw() {
  // 随机移动
  walker.x += random(-5, 5);
  walker.y += random(-5, 5);

  // 边界检查
  walker.x = constrain(walker.x, 0, width);
  walker.y = constrain(walker.y, 0, height);

  // 绘制轨迹
  stroke(255, 50);
  strokeWeight(2);
  point(walker.x, walker.y);
}
```

---

## 粒子系统

### 基础粒子

```javascript
class Particle {
  constructor(x, y) {
    this.pos = createVector(x, y);
    this.vel = p5.Vector.random2D().mult(random(1, 3));
    this.acc = createVector(0, 0);
    this.lifespan = 255;
    this.size = random(5, 15);
    this.color = color(random(150, 255), random(100, 200), random(200, 255));
  }

  applyForce(force) {
    this.acc.add(force);
  }

  update() {
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
    this.lifespan -= 2;
  }

  display() {
    noStroke();
    fill(red(this.color), green(this.color), blue(this.color), this.lifespan);
    ellipse(this.pos.x, this.pos.y, this.size);
  }

  isDead() {
    return this.lifespan <= 0;
  }
}

// 使用
let particles = [];

function setup() {
  createCanvas(800, 800);
}

function draw() {
  background(20, 20);

  // 添加新粒子
  if (mouseIsPressed) {
    particles.push(new Particle(mouseX, mouseY));
  }

  // 更新和绘制
  for (let i = particles.length - 1; i >= 0; i--) {
    particles[i].applyForce(createVector(0, 0.05)); // 重力
    particles[i].update();
    particles[i].display();

    if (particles[i].isDead()) {
      particles.splice(i, 1);
    }
  }
}
```

---

## 流场 (Flow Field)

```javascript
let cols, rows;
let scale = 20;
let zoff = 0;
let particles = [];
let flowField;

function setup() {
  createCanvas(800, 800);
  cols = floor(width / scale);
  rows = floor(height / scale);
  flowField = new Array(cols * rows);

  for (let i = 0; i < 1000; i++) {
    particles[i] = new Particle();
  }

  background(20);
}

function draw() {
  // 生成流场
  let yoff = 0;
  for (let y = 0; y < rows; y++) {
    let xoff = 0;
    for (let x = 0; x < cols; x++) {
      let angle = noise(xoff, yoff, zoff) * TWO_PI * 2;
      let v = p5.Vector.fromAngle(angle);
      v.setMag(0.5);
      flowField[x + y * cols] = v;
      xoff += 0.1;
    }
    yoff += 0.1;
  }
  zoff += 0.003;

  // 更新粒子
  for (let p of particles) {
    p.follow(flowField);
    p.update();
    p.edges();
    p.show();
  }
}

class Particle {
  constructor() {
    this.pos = createVector(random(width), random(height));
    this.vel = createVector(0, 0);
    this.acc = createVector(0, 0);
    this.maxSpeed = 2;
    this.prevPos = this.pos.copy();
  }

  follow(vectors) {
    let x = floor(this.pos.x / scale);
    let y = floor(this.pos.y / scale);
    let index = x + y * cols;
    let force = vectors[index];
    if (force) this.applyForce(force);
  }

  applyForce(force) {
    this.acc.add(force);
  }

  update() {
    this.vel.add(this.acc);
    this.vel.limit(this.maxSpeed);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }

  show() {
    stroke(255, 5);
    strokeWeight(1);
    line(this.pos.x, this.pos.y, this.prevPos.x, this.prevPos.y);
    this.updatePrev();
  }

  updatePrev() {
    this.prevPos = this.pos.copy();
  }

  edges() {
    if (this.pos.x > width) { this.pos.x = 0; this.updatePrev(); }
    if (this.pos.x < 0) { this.pos.x = width; this.updatePrev(); }
    if (this.pos.y > height) { this.pos.y = 0; this.updatePrev(); }
    if (this.pos.y < 0) { this.pos.y = height; this.updatePrev(); }
  }
}
```

---

## 分形图案

### 递归树

```javascript
let angle;

function setup() {
  createCanvas(800, 800);
}

function draw() {
  background(20);
  angle = map(mouseX, 0, width, 0, PI / 2);

  stroke(255);
  strokeWeight(1);
  translate(width / 2, height);
  branch(200);
}

function branch(len) {
  line(0, 0, 0, -len);
  translate(0, -len);

  if (len > 4) {
    push();
    rotate(angle);
    branch(len * 0.67);
    pop();

    push();
    rotate(-angle);
    branch(len * 0.67);
    pop();
  }
}
```

### L-系统

```javascript
let axiom = 'F';
let sentence = axiom;
let len = 100;
let rules = [
  { a: 'F', b: 'FF+[+F-F-F]-[-F+F+F]' }
];

function generate() {
  let nextSentence = '';
  for (let char of sentence) {
    let found = false;
    for (let rule of rules) {
      if (char === rule.a) {
        nextSentence += rule.b;
        found = true;
        break;
      }
    }
    if (!found) nextSentence += char;
  }
  sentence = nextSentence;
  len *= 0.5;
}

function turtle() {
  background(20);
  resetMatrix();
  translate(width / 2, height);
  stroke(100, 200, 100);
  strokeWeight(1);

  for (let char of sentence) {
    if (char === 'F') {
      line(0, 0, 0, -len);
      translate(0, -len);
    } else if (char === '+') {
      rotate(radians(25));
    } else if (char === '-') {
      rotate(radians(-25));
    } else if (char === '[') {
      push();
    } else if (char === ']') {
      pop();
    }
  }
}

function setup() {
  createCanvas(800, 800);
  for (let i = 0; i < 4; i++) generate();
  turtle();
}
```

---

## 对称图案

### 万花筒效果

```javascript
let symmetry = 8;
let angle = 360 / symmetry;

function setup() {
  createCanvas(800, 800);
  background(20);
}

function draw() {
  translate(width / 2, height / 2);

  if (mouseIsPressed) {
    let mx = mouseX - width / 2;
    let my = mouseY - height / 2;
    let pmx = pmouseX - width / 2;
    let pmy = pmouseY - height / 2;

    stroke(255, 150);
    strokeWeight(2);

    for (let i = 0; i < symmetry; i++) {
      rotate(radians(angle));
      line(mx, my, pmx, pmy);
      push();
      scale(1, -1);
      line(mx, my, pmx, pmy);
      pop();
    }
  }
}
```

### 曼陀罗

```javascript
function setup() {
  createCanvas(800, 800);
  noLoop();
}

function draw() {
  background(20);
  translate(width / 2, height / 2);

  let layers = 8;
  let petalsPerLayer = 12;

  for (let layer = 0; layer < layers; layer++) {
    let radius = map(layer, 0, layers, 50, 350);
    let hue = map(layer, 0, layers, 0, 255);

    for (let i = 0; i < petalsPerLayer; i++) {
      push();
      rotate(TWO_PI / petalsPerLayer * i);

      // 花瓣形状
      colorMode(HSB);
      fill(hue, 200, 200, 150);
      noStroke();

      beginShape();
      for (let a = 0; a < PI; a += 0.1) {
        let x = radius * sin(a);
        let y = radius * cos(a) * 0.5 - radius * 0.3;
        vertex(x, y);
      }
      endShape(CLOSE);

      pop();
    }
  }
}
```

---

## 动画与输出

### 循环动画

```javascript
let totalFrames = 120;
let counter = 0;

function setup() {
  createCanvas(800, 800);
}

function draw() {
  background(20);

  // 0-1 循环进度
  let t = (counter % totalFrames) / totalFrames;

  // 使用 sin 创建平滑循环
  let x = width / 2 + sin(t * TWO_PI) * 200;
  let y = height / 2 + cos(t * TWO_PI) * 200;

  fill(255);
  noStroke();
  ellipse(x, y, 50);

  counter++;
}
```

### 保存图像

```javascript
function setup() {
  createCanvas(800, 800);
  noLoop();
}

function draw() {
  background(20);
  // 绘制内容...
}

function keyPressed() {
  if (key === 's') {
    saveCanvas('artwork', 'png');
  }
}

// 保存 GIF（需要 gif.js 库）
function saveGif() {
  // 使用 CCapture.js 或类似库
}
```

---

## 配色方案

### 调色板生成

```javascript
// 单色方案
function monochromaticPalette(baseHue, count) {
  colorMode(HSB);
  let colors = [];
  for (let i = 0; i < count; i++) {
    let saturation = map(i, 0, count, 50, 100);
    let brightness = map(i, 0, count, 100, 50);
    colors.push(color(baseHue, saturation, brightness));
  }
  return colors;
}

// 互补色方案
function complementaryPalette(baseHue) {
  colorMode(HSB);
  return [
    color(baseHue, 80, 90),
    color((baseHue + 180) % 360, 80, 90)
  ];
}

// 三元色方案
function triadicPalette(baseHue) {
  colorMode(HSB);
  return [
    color(baseHue, 80, 90),
    color((baseHue + 120) % 360, 80, 90),
    color((baseHue + 240) % 360, 80, 90)
  ];
}

// 渐变色
function gradientColor(c1, c2, t) {
  return lerpColor(c1, c2, t);
}
```

---

## 与 TAD 框架的集成

在 TAD 的创意流程中：

```
创意需求 → 概念探索 → 算法设计 → 生成作品 → 迭代优化
               ↓
          [ 此 Skill ]
```

**使用场景**：
- NFT 数字艺术创作
- 动态背景/壁纸生成
- 音乐可视化
- 数据艺术化展示
- 品牌视觉资产生成

---

## 创作技巧

```
✅ 推荐
□ 从简单开始，逐步增加复杂度
□ 使用噪声而非纯随机
□ 保持参数可调节
□ 设置随机种子以复现结果
□ 导出高分辨率版本

❌ 避免
□ 过多元素导致混乱
□ 忽略性能优化
□ 硬编码所有参数
□ 只使用默认颜色
```

---

## 灵感来源

- [OpenProcessing](https://openprocessing.org/) - p5.js 作品社区
- [Generative Artistry](https://generativeartistry.com/) - 教程
- [The Coding Train](https://thecodingtrain.com/) - 视频教程
- [Shadertoy](https://www.shadertoy.com/) - 着色器艺术

---

*此 Skill 帮助 Claude 创作独特的生成艺术作品。*
