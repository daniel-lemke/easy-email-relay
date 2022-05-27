/*
 * Copyright 2022 Daniel J. Lemke <dlemke@taklesoftware.com>
 * This software is licensed under the MIT License. See LICENSE for details.
 */
window.onload = function() {
    console.log('starting interval');
    get_log();
    setInterval(get_log, 60000);
};

function get_log() {
    fetch('/get_log').then(r => r.text()).then(d => {
        let log = document.querySelector('#log');
        log.value = d;
        console.log(d);
    });
}

function get_options() {
    fetch('/get_options').then(r => r.text()).then(d => {
        // Can I iterate through form children and check ids, if I find a match
        // between the id and the option key then set the id value to the value?
        // While this may be generally work, i think i would still have to code
        // against certain edge cases such as select elements.
        console.log(d);
    });
}

function start_server() {
    // cgi call
}

function stop_server() {
    // cgi call
}

function show_options() {
    show_div('options_div');
}

function show_help() {
    show_div('help_div');
}

function show_log() {
    show_div('log_div');
}

function show_div(name) {
    let main = document.querySelector('#main_div');
    let div = document.querySelector('#' + name);

    for (var i = 0; i < main.children.length; i++) {
        main.children[i].classList.add('hide');
    }

    div.classList.remove('hide');
}
