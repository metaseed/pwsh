var canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");

//making the canvas full screen
canvas.height = window.innerHeight;
canvas.width = window.innerWidth;

//chinese characters - taken from the unicode charset
var chinese = "田由甲申甴电甶男甸甹町画甼甽甾甿畀畁畂畃畄畅畆畇畈畉畊畋界畍畎畏畐畑абвгдеёжзийклмнопрстуфхцчщъыэюя      ";
//converting the string into an array of single characters
chinese = chinese.split("");

var font_size = 18;
//number of columns for the rain
var columns = canvas.width/font_size; 
//an array of drops - one per column
var drops = [];
//x: the x coordinate
//drops[x]: y co-ordinate of the drop
for(var x = 0; x < columns; x++)
	drops[x] = 1; // initial value of y

//drawing the characters
function draw()
{
	// Black BG for the canvas
	// translucent BG to show trail, increase the alphy value to short the tail
   // cover the cavas with the half transant black rectangle
	ctx.fillStyle = "rgba(0, 0, 0, 0.12)";
	ctx.fillRect(0, 0, canvas.width, canvas.height);
   
	let rn = Math.floor(Math.random() * 255);
	ctx.fillStyle = `rgb(0,${rn+90},${rn-120})`; // green/yellow
	ctx.font = font_size + "px arial";
	//looping over columns
	for(var i = 0; i < drops.length; i++)
	{
		//a random chinese character to print
		var text = chinese[Math.floor(Math.random()*chinese.length)];
		const x = i*font_size, y = drops[i]*font_size
		ctx.fillText(text, x, y);
		
		//sending the drop back to the top randomly after it has crossed the screen
		//adding a randomness to the reset, to make the drops scattered on the Y axis
		if(drops[i]*font_size > canvas.height && Math.random() > 0.975)
			drops[i] = 0;
		
		//incrementing Y coordinate
		drops[i]++;
	}
}

setInterval(draw, 60);

/// record
isRecording = false;
let mediaRecorder;
const recordBtn = document.querySelector("button");
recordBtn.addEventListener("click", e=>{
   isRecording  = !isRecording;
   recordBtn.textContent =isRecording?'stop recording':'start recording'
   if(isRecording) {
      const stream = canvas.captureStream(25);
      mediaRecorder = new MediaRecorder(stream, {
         mimeType: 'video/webm;codecs=vp9',
         ignoreMutedMedia: true
      });
      recordedChunks = [];
      mediaRecorder.ondataavailable = e => {
         if(e.data.size > 0){
            recordedChunks.push(e.data);
         }
      };
      mediaRecorder.start();
   } else {
      mediaRecorder.stop();
      setTimeout(() => {
         const blob = new Blob(recordedChunks, {
            type: "video/webm"
         });
         const url = URL.createObjectURL(blob);
         const a = document.createElement("a");
         a.href = url;
         a.download = "matrixRain.webm";
         a.click();
         URL.revokeObjectURL(url);
      },0);
   }
})


/// gif
// ffmpeg -y -i matrixRain.webm -vf palettegen palette.png
// r: frame rage
// ffmpeg -y -i matrixRain.webm -i palette.png -filter_complex paletteuse -r 10 matrixRain.gif