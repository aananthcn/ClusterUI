from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMakeDeps


class ClusterUIConan(ConanFile):
    name = "ClusterUI"
    version = "0.1"
    settings = "os", "compiler", "build_type", "arch"

    def requirements(self):
        self.requires("grpc/1.69.0")       # must match vhal-core/packages/vhal-ipc-grpc/conanfile.py
        # Qt is NOT managed by Conan — use the locally installed Qt.
        # Pass -DCMAKE_PREFIX_PATH=<qt-install-dir> to cmake instead.
        # Do NOT add protobuf here — gRPC pulls it in transitively.
        # jsoncpp is a vhal-server dependency only — not needed by ClusterUI.

    def generate(self):
        tc = CMakeToolchain(self)
        tc.generate()
        CMakeDeps(self).generate()
