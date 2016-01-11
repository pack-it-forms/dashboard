pack-it-forms dashboard
=======================

The dashboard is a web application that summarizes the contents of
[pack-it-forms](https://github.com/pack-it-forms/pack-it-forms)
messages.

The initial version of the dashboard is being implemented to support
emergency preparedness efforts in the city of Los Altos, CA.
Currently it summarizes damage assessment information reported using
the
[Los Altos Damage Assessment form](https://github.com/pack-it-forms/pack-it-forms/blob/master/form-los-altos-da.html)
and displays it on a map of the city.  Over time it is planned that it
will be generalized to support damage assessment in arbitrary
geographic areas and eventually other related information display
purposes.

Usage Basics
============

The preferred method of running the dashboard server is in a docker
container.  We are not currently publishing the container on Docker Hub
so the only way to create a container to run is to build it.  See the
Contributing section for more information on how to do that.  The
following command, when run in the root directory of this repository,
will start the container properly.

    docker run --rm -p 127.0.0.1:3000:3000 -v $PWD/msgs:/var/www/msgs pack-it-forms/dashboard

The -p option to this command publishes the port for the webserver on
the localhost.  If you change the IP address or port number it is
necessary to inform the server in the container of the values being
used through environment variables.  This can be done with the -e
option to docker run.  For example, to use the IP address 192.168.1.1
(assuming your host has that IP on an interface) and the port 80, you
could use the command:

    docker run --rm -p 192.168.1.1:80:3000 -e HOST=192.168.1.1 -e PORT=80 -e APPROOT=http://192.168.1.1:80/ -v $PWD/msgs:/var/www/msgs pack-it-forms/dashboard

The -v option to this command mounts the host directory named "msgs"
in the current directory inside the container at /var/www/msgs.  This
is the directory that the server watches for message files to read to
update the display.  You can, of course use a different directory on
the host.  The directory used in the container can be changed with the
MSGS_DIR environment variable.


Contributing
============

Toolchain, Building, & Testing
------------------------------

For repeatable builds we are using the "stack" build tool and the
associated curated repositories.  For additional information on
setting up the toolchain, and building/testing see the instructions in
the Contributing section of the
[pack-it-forms msgfmt repo](https://github.com/pack-it-forms/).

Creating the Docker Container
-----------------------------

The first step in creating the docker container is to use stack to
create one from the built server binary.  Just run:

    stack image container

This builds a container called pack-it-forms-dashboard-webapp.  For
some projects the stack generated container is sufficient, but for the
dashboard we want to customize the container a bit in ways that stack
doesn't fully support.  To do so, we build another container, based on
the stack-built container, using docker directly with:

    (cd docker/dashboard && docker build -t pack-it-forms/dashboard .)

If you'd like to specify a container version tag, which is what we
typically do when preparing an image for loading onto a server, you
can replace 0.0.0 with the version you are creating in the following
command:

    (cd docker/dashboard && docker build -t pack-it-forms/dashboard:0.0.0 .)

Saving an Image for Loading a Server Machine
--------------------------------------------

The machine we use to run the dashboard server (not yet released) has
an update system that uses uses exported docker images.  Since the
image format doesn't include the tag (with the version) we export to a
name including that information.  To create a properly named image,
replace both instances 0.0.0 in this command with the proper version
number:

    (cd docker/dashboard && docker export pack-it-forms/dashboard:0.0.0.0 > pack-it-forms_dashboard-0.0.0.dockerimg)
