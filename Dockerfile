ARG PROJECT

FROM ros:noetic-ros-core-focal AS coordinate_conversion_requirements_base

ARG PROJECT
ARG REQUIREMENTS_FILE="requirements.${PROJECT}.ubuntu20.04.system"


RUN mkdir -p /tmp/${PROJECT}
WORKDIR /tmp/${PROJECT}
copy files/${REQUIREMENTS_FILE} /tmp/${PROJECT}


# Step 0: Allow insecure repos temporarily
RUN echo 'Acquire::AllowInsecureRepositories "true";' > /etc/apt/apt.conf.d/99insecure && \
    echo 'Acquire::Check-Valid-Until "false";' >> /etc/apt/apt.conf.d/99insecure

# Step 1: Install curl, gnupg2, etc.
RUN apt-get update && apt-get install -y --no-install-recommends curl gnupg2 ca-certificates

# Step 2: Replace the expired key (used by ROS repo already present in base image)
RUN curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | \
    gpg --dearmor --no-tty --batch --yes -o /usr/share/keyrings/ros1-latest-archive-keyring.gpg


# Step 3: Remove insecure workaround
RUN rm /etc/apt/apt.conf.d/99insecure

RUN apt-get update && \
    apt-get install --no-install-recommends -y checkinstall && \
    xargs apt-get install --no-install-recommends -y < ${REQUIREMENTS_FILE} && \
    rm -rf /var/lib/apt/lists/*

COPY ${PROJECT} /tmp/${PROJECT}/${PROJECT}


FROM coordinate_conversion_requirements_base AS coordinate_conversion_builder

ARG PROJECT

WORKDIR /tmp/${PROJECT}/${PROJECT}
RUN mkdir -p build 
SHELL ["/bin/bash", "-c"]
WORKDIR /tmp/${PROJECT}/${PROJECT}/build

RUN cmake .. -DBUILD_adore_TESTING=ON -DCMAKE_PREFIX_PATH=install -DCMAKE_INSTALL_PREFIX:PATH=install && \
    cmake --build . --config Release --target install -- -j $(nproc) && \
    cpack -G DEB && find . -type f -name "*.deb" | xargs mv -t .  && \
    mv CMakeCache.txt CMakeCache.txt.build 


FROM alpine:3.14

ARG PROJECT
#COPY --from=coordinate_conversion_builder /tmp/${PROJECT} /tmp/${PROJECT}
COPY --from=coordinate_conversion_builder /tmp/${PROJECT}/${PROJECT} /tmp/${PROJECT}/${PROJECT}

