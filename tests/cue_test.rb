$LOAD_PATH << 'lib/'
require 'minitest/autorun'
require 'webvtt'

class ParserTest < Minitest::Test
  def test_build_cue
    cue = WebVTT::Cue.new
    cue.start = WebVTT::Timestamp.new 0
    cue.end = WebVTT::Timestamp.new 12
    cue.text = 'Built from scratch'
    output = ''
    output << "00:00:00.000 --> 00:00:12.000\n"
    output << 'Built from scratch'
    assert_equal output, cue.to_webvtt
  end

  def test_class_build
    cue = WebVTT::Cue.build(start_sec: 0, end_sec: 12, text: 'Built from scratch')
    output = ''
    output << "00:00:00.000 --> 00:00:12.000\n"
    output << 'Built from scratch'
    assert_equal output, cue.to_webvtt
  end

  def test_class_build_with_identifier
    cue = WebVTT::Cue.build(start_sec: 0, end_sec: 12, text: 'Built from scratch', identifier: 1)
    output = ''
    output << "1\n"
    output << "00:00:00.000 --> 00:00:12.000\n"
    output << 'Built from scratch'
    assert_equal output, cue.to_webvtt
  end

  def test_class_build_with_style
    cue = WebVTT::Cue.build(start_sec: 0, end_sec: 12, text: 'Built from scratch', identifier: 1, style: { align: 'middle', line: '0%' })
    output = ''
    output << "1\n"
    output << "00:00:00.000 --> 00:00:12.000 align:middle line:0%\n"
    output << 'Built from scratch'
    assert_equal output, cue.to_webvtt
  end

  def test_list_cues
    webvtt = WebVTT.read('tests/subtitles/test.vtt')
    assert_instance_of Array, webvtt.cues
    assert !webvtt.cues.empty?, 'Cues should not be empty'
    assert_instance_of WebVTT::Cue, webvtt.cues[0]
    assert_equal 15, webvtt.cues.size
  end

  def test_timestamp_in_sec
    assert_equal 60.0, WebVTT::Cue.timestamp_in_sec('00:01:00.000')
    assert_equal 126.23, WebVTT::Cue.timestamp_in_sec('00:02:06.230')
    assert_equal 5159.892, WebVTT::Cue.timestamp_in_sec('01:25:59.892')
  end

  def test_cue_offset_by
    cue = WebVTT::Cue.parse <<-CUE
    00:00:01.000 --> 00:00:25.432
    Test Cue
    CUE
    assert_equal 1.0, cue.start.to_f
    assert_equal 25.432, cue.end.to_f
    cue.offset_by( 12.0 )
    assert_equal 13.0, cue.start.to_f
    assert_equal 37.432, cue.end.to_f
  end

  def test_can_validate_webvtt_with_carriage_returns
    webvtt = WebVTT::File.new('tests/subtitles/test_carriage_returns.vtt')
    assert_instance_of Array, webvtt.cues
    assert !webvtt.cues.empty?, 'Cues should not be empty'
    assert_instance_of WebVTT::Cue, webvtt.cues[0]
    assert_equal 15, webvtt.cues.size
  end
end
