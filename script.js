let windowbtn = document.querySelector(".window");
let windowSet = document.querySelector("#Setting-class")
let status = false;
windowbtn.addEventListener('click',()=>{
    if(!status){
        windowSet.classList.remove('hideclass');
        status=true;
    }
    else{
        windowSet.classList.add('hideclass');
        status=false;
    }
})
//update clock
let time = document.querySelector(".time");
let date = document.querySelector(".date");
const updateTimeDate =()=>{
    const now = new Date();
    const day = String(now.getDate());
    const month = String(now.getMonth());
    const year = String(now.getFullYear());
    const hr = String(now.getHours()).padStart(2,'0');
    const min = String(now.getMinutes()).padStart(2,'0');
    const sec = String(now.getSeconds()).padStart(2,'0');
    const timestring = `${hr}:${min}:${sec}`;
    const datestring = `${day}-${month}-${year}`;
    time.textContent = timestring;
    date.textContent = datestring;
}
updateTimeDate();
setInterval(updateTimeDate,1000);

//Search on click change
let searchdiv = document.querySelector(".searchdiv");
let inputtext = document.querySelector(".inputText");
inputtext.addEventListener('focus',()=>{
    searchdiv.style.backgroundColor = "white";
    
})
inputtext.addEventListener('blur',()=>{
    searchdiv.style.backgroundColor = "rgb(48, 47, 47)";
    
})
//Setting Part Onclick => Blue color
let btmidbox = document.querySelectorAll(".btmidbox");
btmidbox.forEach(ele =>{
    ele.addEventListener('click',()=>{
        ele.classList.toggle('active');
    })
})
//Wifi Status is ON or NOT
let wifistatus = document.querySelector(".wifiStatus");
let wifist = true;
let wifiIcon = document.querySelector(".wifiIcon");
let wifiIcon2 = document.querySelector(".wifiIcon2");
wifistatus.addEventListener('click',()=>{
        if(wifist){
        wifiIcon.src = './icons/without-internet-32-white.png';
        wifiIcon2.src = './icons/without-internet-32-white.png';
        wifist=false;
    }
    else{
        wifiIcon.src = './icons/wifi-32 setting.png';
        wifiIcon2.src = './icons/wifi-32 setting.png';
        wifist=true;
    }
});
//Britness Level
const slider = document.getElementById("brightnessSlider");
const valueDisplay = document.getElementById("brightnessValue");

slider.addEventListener("input", () => {
  const brightness = slider.value;
  document.body.style.filter = `brightness(${brightness})`;
  valueDisplay.textContent = brightness;
});
//Open Notification
let noti = document.querySelector(".setting");
let notidiv = document.querySelector(".bottom-right")
let notist = false;
noti.addEventListener('click',()=>{
    if(!notist){
        notidiv.classList.remove('hideset');
        notist=true;
    }
    else{
        notidiv.classList.add('hideset');
        notist=false;
    }
})
//maximize Window
let maxi = document.querySelectorAll(".maxi");
maxi.forEach(ele =>{
    ele.addEventListener('click',(e)=>{
        let par = e.target.parentNode;
        let gparent = par.parentNode;
        gparent.classList.toggle("maximized");
    })
})

//vscode part
let vscodediv = document.querySelector(".vscodediv");
let vscross = document.querySelector(".vscodecross");
let btvs = document.querySelector('.btvs');
let vsSt = false;
btvs.addEventListener('click',()=>{
    vscodediv.classList.toggle("maximized");
     if(!vsSt){
        vscodediv.classList.remove('hideclass');
        btvs.style.borderBottom = "2px solid blue";
        btvs.style.backgroundColor="rgba(199, 198, 198, 0.897)";
        vsSt=true;
    }
})
document.querySelector('.vscodeIcon').onclick = function() {
    if(!vsSt){
        vscodediv.classList.remove('hideclass');
        btvs.style.borderBottom = "2px solid blue";
        btvs.style.backgroundColor="rgba(199, 198, 198, 0.897)";
        vsSt=true;
    }
};
vscross.addEventListener('click',()=>{
    vscodediv.classList.add('hideclass');
    btvs.style.borderBottom = "none";
    btvs.style.backgroundColor="";
    vsSt=false;
})

//this Pc Part
let thispcdiv = document.querySelector(".thispcdiv");
let thispccross = document.querySelector(".thispccross");
let pcSt = false;
document.querySelector('.thispcIcon').onclick = function() {
    if(!pcSt){
        thispcdiv.classList.remove('hideclass');
        pcSt=true;
    }
};
thispccross.addEventListener('click',()=>{
    thispcdiv.classList.add('hideclass');
    pcSt=false;
})
//Copilet part
let copilotdiv = document.querySelector(".copilotdiv");
let copilotcross = document.querySelector(".copilotcross");
let btco = document.querySelector('.btco');
let coSt = false;
btco.addEventListener('click',()=>{
    copilotdiv.classList.toggle("maximized");
     if(!coSt){
        copilotdiv.classList.remove('hideclass');
        btco.style.borderBottom = "2px solid blue";
        btco.style.backgroundColor="rgba(199, 198, 198, 0.897)";
        coSt=true;
    }
})
document.querySelector('.copilotIcon').onclick = function() {
    if(!coSt){
        copilotdiv.classList.remove('hideclass');
        btco.style.borderBottom = "2px solid blue";
        btco.style.backgroundColor="rgba(199, 198, 198, 0.897)";
        coSt=true;
    }
};
copilotcross.addEventListener('click',()=>{
    copilotdiv.classList.add('hideclass');
    btco.style.borderBottom = "none";
    btco.style.backgroundColor="";
    coSt=false;
})
//Edge part
let edgediv = document.querySelector(".edgediv");
let edgecross = document.querySelector(".edgecross");
let bted = document.querySelector('.bted');
let edSt = false;

bted.addEventListener('click', () => {
    edgediv.classList.toggle("maximized");
    if (!edSt) {
        edgediv.classList.remove('hideclass');
        bted.style.borderBottom = "2px solid blue";
        bted.style.backgroundColor = "rgba(199, 198, 198, 0.897)";
        edSt = true;
    }
});
document.querySelector('.edgeIcon').onclick = () => {
    if (!edSt) {
        edgediv.classList.remove('hideclass');
        bted.style.borderBottom = "2px solid blue";
        bted.style.backgroundColor = "rgba(199, 198, 198, 0.897)";
        edSt = true;
    }
};
edgecross.addEventListener('click', () => {
    edgediv.classList.add('hideclass');
    bted.style.borderBottom = "none";
    bted.style.backgroundColor = "";
    edSt = false;
});
//Games part
let gamesdiv = document.querySelector(".gamesdiv");
let foldercross = document.querySelector(".foldercross");
let btfo = document.querySelector('.btfo');
let foSt = false;

btfo.addEventListener('click', () => {
    gamesdiv.classList.toggle("maximized");
    if (!foSt) {
        gamesdiv.classList.remove('hideclass');
        btfo.style.borderBottom = "2px solid blue";
        btfo.style.backgroundColor = "rgba(199, 198, 198, 0.897)";
        foSt = true;
    }
});
document.querySelector('.folderIcon').onclick = () => {
    if (!foSt) {
        gamesdiv.classList.remove('hideclass');
        btfo.style.borderBottom = "2px solid blue";
        btfo.style.backgroundColor = "rgba(199, 198, 198, 0.897)";
        foSt = true;
    }
};
foldercross.addEventListener('click', () => {
    gamesdiv.classList.add('hideclass');
    btfo.style.borderBottom = "none";
    btfo.style.backgroundColor = "";
    foSt = false;
});
//Brave part
let bravediv = document.querySelector(".bravediv");
let bravecross = document.querySelector(".bravecross");
let btbr = document.querySelector('.btbr');
let brSt = false;

btbr.addEventListener('click', () => {
    bravediv.classList.toggle("maximized");
    if (!brSt) {
        bravediv.classList.remove('hideclass');
        btbr.style.borderBottom = "2px solid blue";
        btbr.style.backgroundColor = "rgba(199, 198, 198, 0.897)";
        brSt = true;
    }
});
document.querySelector('.braveIcon').onclick = () => {
    if (!brSt) {
        bravediv.classList.remove('hideclass');
        btbr.style.borderBottom = "2px solid blue";
        btbr.style.backgroundColor = "rgba(199, 198, 198, 0.897)";
        brSt = true;
    }
};
bravecross.addEventListener('click', () => {
    bravediv.classList.add('hideclass');
    btbr.style.borderBottom = "none";
    btbr.style.backgroundColor = "";
    brSt = false;
});
//vlc part
let vlcdiv = document.querySelector(".vlcdiv");
let vlccross = document.querySelector(".vlccross");
let btvl = document.querySelector('.btvl');
let vlSt = false;

btvl.addEventListener('click', () => {
    vlcdiv.classList.toggle("maximized");
    if (!vlSt) {
        vlcdiv.classList.remove('hideclass');
        btvl.style.borderBottom = "2px solid blue";
        btvl.style.backgroundColor = "rgba(199, 198, 198, 0.897)";
        vlSt = true;
    }
});
document.querySelector('.vlcIcon').onclick = () => {
    if (!vlSt) {
        vlcdiv.classList.remove('hideclass');
        btvl.style.borderBottom = "2px solid blue";
        btvl.style.backgroundColor = "rgba(199, 198, 198, 0.897)";
        vlSt = true;
    }
};
vlccross.addEventListener('click', () => {
    vlcdiv.classList.add('hideclass');
    btvl.style.borderBottom = "none";
    btvl.style.backgroundColor = "";
    vlSt = false;
});

//cohort part
let cohortdiv = document.querySelector(".cohortdiv");
let cohortcross = document.querySelector(".cohortcross");
let cohort = document.querySelector('.cohort');
let chSt = false;

cohort.addEventListener('click', () => {
    cohortdiv.classList.toggle("maximized");
    if (!chSt) {
        cohortdiv.classList.remove('hideclass');
        cohort.style.borderBottom = "2px solid blue";
        cohort.style.backgroundColor = "rgba(199, 198, 198, 0.897)";
        chSt = true;
    }
});
document.querySelector('.cohort').onclick = () => {
    if (!chSt) {
        cohortdiv.classList.remove('hideclass');
        cohort.style.borderBottom = "2px solid blue";
        cohort.style.backgroundColor = "rgba(199, 198, 198, 0.897)";
        chSt = true;
    }
};
cohortcross.addEventListener('click', () => {
    cohortdiv.classList.add('hideclass');
    cohort.style.borderBottom = "none";
    cohort.style.backgroundColor = "";
    chSt = false;
});

