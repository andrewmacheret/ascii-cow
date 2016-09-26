var express = require('express');
//var bodyParser = require('body-parser');
var child_process = require('child_process');

var app = express();
//app.use(bodyParser.json());

// cowsay:
// (or cowthink)
//  -e <eyestring> ("oo" by default)
//  -l       - lists cowfiles
//  -T <tonguestring> (empty by default)
// -bdgpstwy  - borg, dead, greedy, paranoia, stoned, tired, wired, youthful
// -f cowfile

// {-f|--file}          <IMAGE-FILE>    | SOURCE |
// {-u|--url}           <IMAGE-URL>     | SOURCE |

// {-w|--width}         <WIDTH>         | SIZE   |
// {-h|--height}        <HEIGHT>        | SIZE   |
// {-a|--aspect-ratio}  <WIDTH:HEIGHT>  | SIZE   | 4:3

// {-s|--cowsay}                        | OTHER  | yes
// {-t|--cowthink}                      | OTHER  |

// {-c|--cow-args}      <COW_ARGS>      | OTHER  |

// {-i|--im2a}          <IM2A_ARGS>     | OTHER  |


/*
actions: convert image to cow, list available cows

eyes: ""
tongue: ""
feeling: "borg|dead|greedy|paranoia|stoned|tired|wired|youthful"
filename: "" | file: ""
cow {
}
*/

var run = function(command, args) {
  return child_process.spawnSync(command, args, {});
};

var invalidInput = function(res, error) {
  res.status(400).send(error);
};

console.log('Registering GET /ascii-cows/_available');
app.get('/ascii-cows/_available', function(req, res) {
  var cowResult = run('cowsay', ['-l']);
  res.send(cowResult.stdout.toString('utf8'));
});

console.log('Registering GET /ascii-cows');
app.get('/ascii-cows', function(req, res) {
  // image source
  var url = req.query['url'];
  var file = req.query['file'];
  if (!url && !file) {
    invalidInput(res, 'Url or file must be specified');
    return;
  }
  if (url && file) {
    invalidInput(res, 'Url and file cannot be both specified');
    return;
  }

  // image
  var width = req.query['width'];
  var height = req.query['height'];
  var aspectRatio = req.query['aspect-ratio'];
  if (!width && !height) {
    invalidInput(res, 'Width or height must be specified');
    return;
  }

  // cow
  var say = req.query['say'] != null || false;
  var think = req.query['think'] != null || false;
  var eyes = req.query['eyes'];
  var tongue = req.query['tongue'];
  var feeling = req.query['feeling'];
  var cowFile = req.query['cow-file'];

  var args = [];
  var cowArgs = [];

  if (url) {
    args.push('--url');
    args.push(url);
  }
  if (file) {
    args.push('--file');
    args.push(file);
  }
  if (width) {
    args.push('--width');
    args.push(width);
  }
  if (height) {
    args.push('--height');
    args.push(height);
  }
  if (aspectRatio) {
    args.push('--aspect-ratio');
    args.push(aspectRatio);
  }
  if (say) {
    args.push('--cow-say');
  }
  if (think) {
    args.push('--cow-think');
  }
  if (eyes) {
    cowArgs.push('-e');
    cowArgs.push(eyes);
  }
  if (tongue) {
    cowArgs.push('-T');
    cowArgs.push(tongue);
  }
  if (feeling) {
    cowArgs.push('-' + feeling[0]);
  }
  if (cowFile) {
    cowArgs.push('-f');
    cowArgs.push(cowFile);
  }

  if (cowArgs) {
    var cowArg = cowArgs.map(function(cowArg) {
      // escape single quotes
      // return cowArg.replace('\'', '\'\\\'\'');
      return cowArg;
    }).join(' ');

    args.push('--cow-args');
    args.push(cowArg);
  }

  //args.push('--im2a-args');
  //args.push('--html');

  var cowResult = run('./ascii-cow.sh', args);

  if (cowResult.error) {
    res.status(500).send({
      error: cowResult.error
    });
  } else if (res.status === 0) {
    res.status(500).send(cowResult.stdout.toString('utf8'));
  } else {
    res.send(cowResult.stdout.toString('utf8'));
  }
});

app.listen(8080, function () {
  console.log('Listening on port 8080');
});

