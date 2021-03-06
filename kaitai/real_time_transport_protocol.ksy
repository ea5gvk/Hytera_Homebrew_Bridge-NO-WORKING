meta:
  id: real_time_transport_protocol
doc: |
  each packet should contain 60ms of voice data for AMBE compatibility
enums:
  rtp_payload_types:
    # G.711 μ-law PCMU
    0: mu_law
    # G.711 a-law PCMA - default
    8: a_law
  call_types:
    0x00: private_call
    0x01: group_call
    0x02: all_call
types:
  radio_id:
    seq:
      - id: radio_id_1
        type: u1
      - id: radio_id_2
        type: u1
      - id: radio_id_3
        type: u1
    instances:
      id:
        value: radio_id_1.to_s + radio_id_2.to_s + radio_id_3.to_s
  fixed_header:
    seq:
      - id: version
        type: b2
      - id: padding
        type: b1
        doc: if set, this packet contains padding bytes at the end
      - id: extension
        type: b1
        doc: if set, fixed header is followed by single header extension
      - id: csrc_count
        type: b4
        doc: number of csrc identifiers that follow fixed header (val. 0-15)
      - id: marker
        type: b1
        doc: marker meaning is defined by RTP profile, for HDAP should be always 0
      - id: payload_type
        type: b7
      - id: sequence_number
        type: u2be
        doc: sequence does not start from 0, but from random number
      - id: timestamp
        type: u4be
        doc: sampling instant of the first octet in this RTP packet
      - id: ssrc
        type: u4be
        doc: synchronized source identifier
      - id: csrc
        type: u4be
        doc: contributing sources
        repeat: expr
        repeat-expr: csrc_count
  header_extension:
    seq:
      - id: header_identifier
        type: u2be
      - id: length
        type: u2be
        doc: number of 32bit words following the header+length fields
      - id: slot
        type: b7
        doc: slot number 1 or 2
      - id: last_flag
        type: b1
        doc: indicates end of voice call
      - id: source_id
        type: radio_id
      - id: destination_id
        type: radio_id
      - id: call_type
        type: u1
        enum: call_types
      - id: reserved
        size: 4
        doc: reserved 32bits
seq:
  - id: fixed_header
    type: fixed_header
  - id: header_extension
    type: header_extension
    if: fixed_header.extension.to_i == 1
  - id: audio_data
    size-eos: true