ARG PROJECT

FROM ros:noetic-ros-core-focal AS coordinate_conversion_requirements_base

ARG PROJECT
ARG REQUIREMENTS_FILE="requirements.${PROJECT}.ubuntu20.04.system"


WORKDIR /tmp/${PROJECT}
copy files/${REQUIREMENTS_FILE} /tmp/${PROJECT}

RUN apt-get update && \
    apt-get install --no-install-recommends -y checkinstall && \
    xargs apt-get install --no-install-recommends -y < ${REQUIREMENTS_FILE} && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/${PROJECT}
COPY ${PROJECT} /tmp/${PROJECT}


FROM coordinate_conversion_requirements_base AS coordinate_conversion_builder

ARG PROJECT

WORKDIR /tmp/${PROJECT}
RUN mkdir -p build 
SHELL ["/bin/bash", "-c"]
WORKDIR /tmp/${PROJECT}/build

RUN source /opt/ros/noetic/setup.bash && \
    cmake .. && \
    cmake --build . --config Release --target install -- -j $(nproc) && \
    cpack -G DEB && find . -type f -name "*.deb" | xargs mv -t . 


FROM alpine:3.14

ARG PROJECT
COPY --from=coordinate_conversion_builder /tmp/${PROJECT} /tmp/${PROJECT}

