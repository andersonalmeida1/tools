var fs = require("fs");

// https://stackoverflow.com/questions/36959253/how-can-i-execute-shell-commands-in-sequence
//var console;


//var commands = ["npm install", "echo 'hello'"];

var exec = require('child_process').exec;

var currentdate = new Date(); 
var datetime = 
                 currentdate.getFullYear() + "-"  + (currentdate.getMonth()+1)  + "-"  +  currentdate.getDate() + "-"
                + currentdate.getHours() + "-" + currentdate.getMinutes() + "-"  + currentdate.getSeconds();

var flog = fs.createWriteStream(datetime+'-log.txt'); 


function log(s)
{
   console.log(s);
   flog.write(s+'\n');    
}


readfile= function (file1,fs)
{
  var arrlines = [];
  var fileContents = fs.readFileSync(file1);
  var lines = fileContents.toString().split('\n');
   //começa em 1 ignora primeira linha de labels
  for (var i = 0; i < lines.length; i++) {
    arrlines.push(lines[i].toString());
    //  log(lines[i]);
  }
  return arrlines;
}


function runCommands(array, nstart_line,callback) {

    var index = 0;
    var results = [];
    log("Starting from line:"+nstart_line);
    index=nstart_line-1;
    function next() {
       if (index < array.length) {
           var c=array[index++];
           //remove newline
           c=c.replace(/(\n|\r)+$/, '')
           var cargs = c.split(" ");
           log('*******************************************************');
           log('['+index+']'+process.cwd()+'> '+c);
           var sparms='';
           for(i=0;i<cargs.length;i++)
              sparms=sparms+' '+cargs[i];
           
           //log(' PARMS:'+cargs[0]+' '+cargs[1]);
           //log('{PARMS:['+sparms+']}');
           //log('cargs[0]:['+cargs[0]+']}');
           //cmd=readAsText();
           if(cargs[0] === 'cd')  {
               if(cargs.length>1) {
                  log('Change dir to:'+cargs[1]);
                   process.chdir(cargs[1]);
                }
               else {
                  log('Change dir to: .');
               }
               next();
           }
           else
           try {
           exec(c, function(err, stdout) {
               if (err)
                  callback(err,stdout,index,array.length); //log data
               callback(null,stdout,index,array.length);   // log data
               next();
           });
           }catch(e){log('ERRO EXEC')};
               
       } 
    }
    // start the first iteration
    next();
}

var file_name = process.argv[2]; 
var start_line = process.argv[3]; 
var nstart_line=1;
if(start_line)
    nstart_line=Number.parseInt(start_line);


var arrfile = readfile(file_name,fs);
log('SDB V1.8 - STARTING ...');
try{
runCommands(arrfile,nstart_line, function(err, results,index,array_length) {
    if(err)
    {
        log(err);
        log('ERROR...Aborting.');
        process.exit();
    }
    else
        log(results);
    
   if(index==array_length){
   log('*******************************************************');
   log("END> Executed "+(index-nstart_line+1)+' lines of total '+array_length);

   }
    

});
}catch(e){log('ERRO RUN COMMANDS:\n'+e)};    
