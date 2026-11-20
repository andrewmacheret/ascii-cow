var http = require('node:http');
var child_process = require('node:child_process');

// cowsay:
// (or cowthink)
//  -e <eyestring> ("oo" by default)
//  -l       - lists cowfiles
//  -T <tonguestring> (empty by default)
// -bdgpstwy  - borg, dead, greedy, paranoia, stoned, tired, wired, youthful
// -f cowfile

// {-f|--file}          <IMAGE-FILE>    | SOURCE | (cli only)
// {-u|--url}           <IMAGE-URL>     | SOURCE |

// {-w|--width}         <WIDTH>         | SIZE   |
// {-h|--height}        <HEIGHT>        | SIZE   |
// {-a|--aspect-ratio}  <WIDTH:HEIGHT>  | SIZE   | 4:3

// {-s|--cowsay}                        | OTHER  | yes
// {-t|--cowthink}                      | OTHER  |

// {-c|--cow-args}      <COW_ARGS>      | OTHER  |

// {-i|--im2a}          <IM2A_ARGS>     | OTHER  |

var FEELINGS = {
  borg: '-b',
  dead: '-d',
  greedy: '-g',
  paranoia: '-p',
  stoned: '-s',
  tired: '-t',
  wired: '-w',
  youthful: '-y'
};

var POSITIVE_INTEGER = /^[1-9][0-9]*$/;
var ASPECT_RATIO = /^[1-9][0-9]*:[1-9][0-9]*$/;
// cow args get split on spaces by the shell script, so no spaces or globs
var EYES_OR_TONGUE = /^[^\s*?[\]]{1,2}$/;
var COW_FILE = /^[A-Za-z0-9_.-]+$/;

var run = function(command, args) {
  return child_process.spawnSync(command, args, {});
};

var send = function(res, status, body) {
  res.statusCode = status;
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.end(body);
};

var invalidInput = function(res, error) {
  send(res, 400, error);
};

var sendResult = function(res, cowResult) {
  if (cowResult.error) {
    send(res, 500, JSON.stringify({
      error: cowResult.error.message
    }));
  } else if (cowResult.status !== 0) {
    send(res, 500, cowResult.stderr.toString('utf8') + cowResult.stdout.toString('utf8'));
  } else {
    send(res, 200, cowResult.stdout.toString('utf8'));
  }
};

var routes = {};

routes['/'] = function(req, res) {
  var baseUrl = 'http://' + req.headers.host;
  var apis = [
    baseUrl + '/cows',
    baseUrl + '/convert'
  ];
  send(res, 200, apis.join('\n'));
};

routes['/cows'] = function(req, res) {
  sendResult(res, run('cowsay', ['-l']));
};

routes['/convert'] = function(req, res, query) {
  // image source
  var url = query.get('url');
  if (!url) {
    invalidInput(res, 'Url must be specified');
    return;
  }
  // curl also reads file:// urls, so only allow http and https
  if (!URL.canParse(url) || !/^https?:$/.test(new URL(url).protocol)) {
    invalidInput(res, 'Url must be an http or https url');
    return;
  }

  // image
  var width = query.get('width');
  var height = query.get('height');
  var aspectRatio = query.get('aspect-ratio');
  if (!width && !height) {
    invalidInput(res, 'Width or height must be specified');
    return;
  }
  if (width && !POSITIVE_INTEGER.test(width)) {
    invalidInput(res, 'Width must be a positive integer');
    return;
  }
  if (height && !POSITIVE_INTEGER.test(height)) {
    invalidInput(res, 'Height must be a positive integer');
    return;
  }
  if (aspectRatio && !ASPECT_RATIO.test(aspectRatio)) {
    invalidInput(res, 'Aspect ratio must be in the format WIDTH:HEIGHT, like 4:3');
    return;
  }

  // cow
  var say = query.has('say');
  var think = query.has('think');
  var eyes = query.get('eyes');
  var tongue = query.get('tongue');
  var feeling = query.get('feeling');
  var cowFile = query.get('cow-file');
  if (eyes && !EYES_OR_TONGUE.test(eyes)) {
    invalidInput(res, 'Eyes must be 1 or 2 characters with no spaces');
    return;
  }
  if (tongue && !EYES_OR_TONGUE.test(tongue)) {
    invalidInput(res, 'Tongue must be 1 or 2 characters with no spaces');
    return;
  }
  if (feeling && !Object.hasOwn(FEELINGS, feeling)) {
    invalidInput(res, 'Feeling must be one of: ' + Object.keys(FEELINGS).join(', '));
    return;
  }
  if (cowFile && !COW_FILE.test(cowFile)) {
    invalidInput(res, 'Cow file must be a name from /cows');
    return;
  }

  var args = [];
  var cowArgs = [];

  args.push('--url');
  args.push(url);
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
    cowArgs.push(FEELINGS[feeling]);
  }
  if (cowFile) {
    cowArgs.push('-f');
    cowArgs.push(cowFile);
  }

  if (cowArgs.length > 0) {
    args.push('--cow-args');
    args.push(cowArgs.join(' '));
  }

  sendResult(res, run('./ascii-cow.sh', args));
};

var server = http.createServer(function(req, res) {
  var requestUrl;
  try {
    requestUrl = new URL('http://localhost' + req.url);
  } catch (e) {
    invalidInput(res, 'Invalid request url');
    return;
  }

  var route = Object.hasOwn(routes, requestUrl.pathname) && routes[requestUrl.pathname];
  if (!route || (req.method !== 'GET' && req.method !== 'HEAD')) {
    send(res, 404, 'Cannot ' + req.method + ' ' + requestUrl.pathname);
    return;
  }

  route(req, res, requestUrl.searchParams);
});

var port = process.env.PORT || 80;
server.listen(port, function () {
  console.log('Listening on port ' + port);
});
