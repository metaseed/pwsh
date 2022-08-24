const SENTENCE_DROPPING = true;
const FONT_SIZE = 18;

const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

//making the canvas full screen
canvas.height = window.innerHeight;
canvas.width = window.innerWidth;

const ROWS = Math.floor(canvas.height / FONT_SIZE); // maybe not int
//number of columns for the rain
const COLUMNS = canvas.width / FONT_SIZE;

// max value(even is int) is not included, return int in [0,maxValue)
function randomInt(maxValue) {
  return Math.floor(Math.random() * maxValue);
}
function randomItem(array) {
  return array[randomInt(array.length)];
}


//chinese characters - taken from the unicode charset
const chinese =
  "道生一，一生二，二生三，三生万物。山穷水复疑无路，柳暗花明又一村。众里寻他千百度，蓦然回首，那人却在灯火阑珊处。千呼万唤始出来，犹抱琵琶半遮面。衣带渐宽终不悔，为伊消得人憔悴。金风玉露一相逢，便胜却人间无数。曾经沧海难为水，除却巫山不是云。忽如一夜春风来，千树万树梨花开。执子之手，与子偕老。采菊东篱下，悠然见南山。无丝竹之乱耳，无案牍之劳形。逝者如斯夫！不舍昼夜。博学之，审问之，慎思之，明辨之，笃行之。上善若水，水善利万物而不争。故不积跬步，无以至千里；不积小流，无以成江海。君子坦荡荡，小人长戚戚。己所不欲，勿施于人。落霞与孤鹜齐飞，秋水共长天一色。不以物喜，不以己悲。夫祸患常积于忽微，而智勇多困于所溺。星月皎洁，明河在天，四无人声，声在树间。野火烧不尽，春风吹又生。但愿人长久，千里共蝉娟。海阔凭鱼跃，天高任鸟飞。小荷才露尖尖角，早有蜻蜓立上头。";


class DropSentences {
  constructor(chinese) {
    this.sentences = chinese.split("。").filter(v=> v.trim() != '');
    this.dropsSentences = [];
    for (let x = 0; x < COLUMNS; x++) {
      this.dropsSentences[x] = { index: 0, chars: randomItem(this.sentences) };
    }
  }

  getChar(column) {
   const sentence =this.dropsSentences[column]
   const char = sentence.chars[sentence.index++]
   if(char == undefined) debugger
   sentence.index %= sentence.chars.length
   return char
  }
}

const dropsSentences = new DropSentences(chinese)

//an array of drops - one per column
const currentRowOfColumns = [];
//x: the x coordinate
//drops[x]: y co-ordinate of the drop
// initial value of y with random value, so not start from top
for (let x = 0; x < COLUMNS; x++) currentRowOfColumns[x] = randomInt(ROWS);

//drawing the characters
function draw() {
  // Black BG for the canvas
  // translucent BG to show trail, increase the alpha value to short the tail
  // cover the canvas with the half transient black rectangle
  ctx.fillStyle = "rgba(0, 0, 0, 0.16)";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  const rn = randomInt(255);// [0,255)
  ctx.fillStyle = `rgb(0,${rn + 90},${rn - 120})`; // green/yellow
  ctx.font = FONT_SIZE + "px arial";
  //looping over columns
  for (let i = 0; i < COLUMNS; i++) {
    //a random chinese character to print
    const char = SENTENCE_DROPPING ? dropsSentences.getChar(i): randomItem(chinese);

    const x = i * FONT_SIZE;
    const y = currentRowOfColumns[i] * FONT_SIZE;
    ctx.fillText(char, x, y);

    //sending the drop back to the top randomly after it has crossed the screen
    //adding a randomness to the reset, to make the drops scattered on the Y axis
    if (currentRowOfColumns[i] * FONT_SIZE > canvas.height && Math.random() > 0.975)
      currentRowOfColumns[i] = 0;

    //incrementing Y coordinate
    currentRowOfColumns[i]++;
  }
}
const rainSpeed = 80;
setInterval(draw, rainSpeed);

/////////////////////////////////////////////////////////////////////
/// record
/////////////////////////////////////////////////////////////////////
let isRecording = false;
let mediaRecorder;
let recordedChunks;
const recordBtn = document.getElementById("recordBtn");
recordBtn.addEventListener("click", (e) => {
  isRecording = !isRecording;
  recordBtn.textContent = isRecording ? "⏹" : "⏺";
  recordBtn.title = isRecording ? "stop recording" : "start recording";

  if (isRecording) {
    const stream = canvas.captureStream(25);
    mediaRecorder = new MediaRecorder(stream, {
      mimeType: "video/webm;codecs=vp9",
      ignoreMutedMedia: true,
    });
    recordedChunks = [];
    mediaRecorder.ondataavailable = (e) => {
      if (e.data.size > 0) {
        recordedChunks.push(e.data);
      }
    };
    mediaRecorder.start();
  } else {
    mediaRecorder.stop();

    // auto download
    setTimeout(() => {
      const blob = new Blob(recordedChunks, {
        type: "video/webm",
      });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = "matrixRain.webm";
      a.click();
      URL.revokeObjectURL(url);
    }, 0);
  }
});

/// convert to gif
// ffmpeg -y -i matrixRain.webm -vf palettegen palette.png
// r: frame rate
// ffmpeg -y -i matrixRain.webm -i palette.png -filter_complex paletteuse -r 10 matrixRain.gif
