# Start with a Base CML Runtime with JupyterLab & add cuda libraries
FROM docker.repository.cloudera.com/cloudera/cdsw/ml-runtime-jupyterlab-python3.9-standard:2022.11.1-b2

USER root

RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa && apt update && apt install -y python3.10
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3.10 1
RUN update-alternatives --install /usr/local/bin/python3 python3 /usr/bin/python3.10 1
# Add images from Nvidia (Using ubuntu18.04 as older packages are available here)
RUN echo "deb [trusted=yes] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
echo "deb [trusted=yes] https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list


ENV CUDA_VERSION 10.0.130
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"

#ENV CUDA_PKG_VERSION 10-2_$CUDA_VERSION-1
ENV CUDA_PKG_VERSION 10-0
RUN apt-get  update --allow-unauthenticated && apt-get install -y --no-install-recommends --allow-unauthenticated \
         cuda-cudart-$CUDA_PKG_VERSION*  cuda-cublas-$CUDA_PKG_VERSION* cuda-cufft-$CUDA_PKG_VERSION* cuda-curand-$CUDA_PKG_VERSION* cuda-cusolver-$CUDA_PKG_VERSION* cuda-cusparse-$CUDA_PKG_VERSION* && \
    ln -s cuda-10.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

RUN echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
    ldconfig

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64


ENV CUDNN_VERSION 8.0.5.39
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"


RUN apt-get update && apt-get  install -y --no-install-recommends --allow-unauthenticated \
            libcudnn8=$CUDNN_VERSION-1+cuda10.1 && \
    apt-mark hold libcudnn8 && \
    rm -rf /var/lib/apt/lists/*


# Override Runtime label and environment variables metadata
ENV ML_RUNTIME_EDITION="Python3.10 CUDA 10" \
	ML_RUNTIME_SHORT_VERSION="2023.03" \
	ML_RUNTIME_MAINTENANCE_VERSION="1" \
    ML_RUNTIME_FULL_VERSION="2023.03.1" \
    ML_RUNTIME_DESCRIPTION="This runtime contains CUDA 10 and cuDNN 8 and Python 3.10"

LABEL com.cloudera.ml.runtime.edition=$ML_RUNTIME_EDITION \
	  com.cloudera.ml.runtime.full-version=$ML_RUNTIME_FULL_VERSION \
      com.cloudera.ml.runtime.short-version=$ML_RUNTIME_SHORT_VERSION \
      com.cloudera.ml.runtime.maintenance-version=$ML_RUNTIME_MAINTENANCE_VERSION \
      com.cloudera.ml.runtime.description=$ML_RUNTIME_DESCRIPTION
