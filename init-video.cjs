const { spawn } = require('child_process');

const child = spawn('npx', ['-y', 'create-video@latest', 'kitamo-promo'], {
    stdio: ['pipe', 'inherit', 'inherit'],
    cwd: process.cwd()
});

setTimeout(() => {
    console.log("Q1: Blank template");
    child.stdin.write('\n');
}, 4000);

setTimeout(() => {
    console.log("Q2: Git submodule warning -> Yes");
    child.stdin.write('\u001b[C\n');
}, 6000);

setTimeout(() => {
    console.log("Q3: Tailwindcss -> Yes");
    child.stdin.write('\u001b[C\n');
}, 8000);

// Just in case it asks for package manager or anything else
setTimeout(() => {
    console.log("Q4: Packager -> Enter");
    child.stdin.write('\n');
}, 10000);

setTimeout(() => {
    console.log("Q5: Confirm -> Enter");
    child.stdin.write('\n');
}, 12000);

// Don't close stdin immediately, let the child process finish installing dependencies
