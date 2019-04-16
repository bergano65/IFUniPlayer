function restart() {
    alert('+');
    }

        function open() {
        window.external.notify("open");
    }

        function save() {
        window.external.notify("save");
    }

        function help() {
        window.external.notify("help");
    }

        function about() {
        window.external.notify("about");
    }

        function play(game) {
        window.external.notify("play-" + game);
    }

