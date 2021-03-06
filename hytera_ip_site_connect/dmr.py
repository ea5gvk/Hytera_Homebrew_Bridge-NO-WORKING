from .generic_service import GenericHyteraService
from .storage import Storage


class DMRHyteraService(GenericHyteraService):
    def run(self) -> None:
        self.create_socket()
        while True:
            try:
                data, address = self.serverSocket.recvfrom(4096)
                ip, port = address
                self.log("data (%d) received from %s.%s" % (len(data), ip, port))
                self.log(data.hex())

                if len(data) == 1 and data[0] == 0x00:
                    # RPTL
                    self.serverSocket.sendto(bytes([0x41]), address)
                    continue

                slot = data[16]
                packetType = data[8]
                slotType = data[18:19]
                frameType = data[22:23]
                self.log(
                    "recv slot:%s packetType:%s slotType:%s frameType:%s"
                    % (hex(slot), hex(packetType), slotType.hex(), frameType.hex())
                )

            except Exception as err:
                self.selfLogger.error(err, exc_info=True)


if __name__ == "__main__":
    t = DMRHyteraService()
    t.set_storage(Storage()).start()
