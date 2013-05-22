require 'snmp/varbind'
require 'test/unit'

class TestVarBind < Test::Unit::TestCase

  include SNMP

  def test_varbind_encode
    v = VarBind.new([1,3,6,1], OctetString.new("test"))
    assert_equal("0\v\006\003+\006\001\004\004test", v.encode)
    assert_not_nil(v.asn1_type)
    assert_equal("[name=1.3.6.1, value=test (OCTET STRING)]", v.to_s)
  end

  def test_varbind_decode
    varbind, remainder = VarBind.decode("0\f\006\010+\006\001\002\001\001\001\000\005\000")
    assert_equal(Null, varbind.value)
    assert_equal("", remainder)

    varbind, remainder = VarBind.decode("0\f\006\010+\006\001\002\001\001\001\000\005\0000\f\006\010+\006\001\002\001\001\002\000\005\000")
    assert_equal(Null, varbind.value)
    assert_equal("0\f\006\010+\006\001\002\001\001\002\000\005\000", remainder)
  end

  def test_varbind_to_s
    mib = MIB.new
    mib.load_module("IF-MIB")

    vb = VarBind.new("1.3.6.1.2.1.2.2.1.2.1.1", OctetString.new("description")).with_mib(mib)
    assert_equal "[name=IF-MIB::ifDescr.1.1, value=description (OCTET STRING)]", vb.to_s

    vb = VarBind.new("1.3.6.1.2.1.2.2.1.2.1.1", ObjectId.new("1.3.6.1.2.1.2.2.1.2.1.1")).with_mib(mib)
    assert_equal "[name=IF-MIB::ifDescr.1.1, value=IF-MIB::ifDescr.1.1 (OBJECT IDENTIFIER)]", vb.to_s
  end

  def test_varbind_name_alias_oid
    vb = VarBind.new("1.2.3.4", OctetString.new("blah"))
    assert_equal(ObjectId.new("1.2.3.4"), vb.name)
    assert_equal(ObjectId.new("1.2.3.4"), vb.oid)
  end

  def test_varbind_list_create
    list = VarBindList.new
    assert_equal(0, list.length)

    check_varbind_list_create(VarBindList.new(["1.2.3.4.5"]))
    check_varbind_list_create(VarBindList.new([ObjectId.new("1.2.3.4.5")]))
    check_varbind_list_create(VarBindList.new([VarBind.new("1.2.3.4.5", Null)]))

    check_varbind_list_create(VarBindList.new(
    ["1.2.3.4.5", "1.2.3.4.6"]), 2)

    check_varbind_list_create(VarBindList.new(
                                [ObjectId.new("1.2.3.4.5"),
                                 ObjectId.new("1.2.3.4.6")]
    ), 2)

    check_varbind_list_create(VarBindList.new(
                                [VarBind.new("1.2.3.4.5", Null),
                                 VarBind.new("1.2.3.4.6", Integer.new(123)),
                                 ObjectId.new("1.2.3.4.7")]
    ), 3)

    list = VarBindList.new([VarBind.new("1.3.6.2", Integer.new(1))])
    assert_equal(1, list.length)
    assert_equal("1.3.6.2", list.first.name.to_s)
    assert_equal(1, list.first.value.to_i)
  end

  def check_varbind_list_create(list, n=1)
    assert_equal(n, list.length)
    assert_equal("1.2.3.4.5", list.first.name.to_s)
    assert_equal(Null, list.first.value)
  end

  def test_varbind_list_encode
    list = VarBindList.new
    assert_equal("0\000", list.encode)
    assert_not_nil(list.asn1_type)

    list << VarBind.new([1,3,6,1], OctetString.new("test"))
    assert_equal("0\r0\v\006\003+\006\001\004\004test", list.encode)

    list << VarBind.new([1,3,6,1], OctetString.new("blah"))
    assert_equal("0\0320\v\006\003+\006\001\004\004test0\v\006\003+\006\001\004\004blah", list.encode)
  end

  def test_varbind_list_decode
    list, remainder = VarBindList.decode("0\r0\v\006\003+\006\001\004\004test")
    assert_equal(1, list.length)
    assert_equal("", remainder)

    list, remainder = VarBindList.decode("0\0320\v\006\003+\006\001\004\004test0\v\006\003+\006\001\004\004blah")
    assert_equal(2, list.length)
    assert_equal("", remainder)

    list, remainder = VarBindList.decode("0\000")
    assert_equal(0, list.length)
    assert_equal("", remainder)
  end

  def test_octet_string
    string = OctetString.new("test")
    assert_equal("test", string.to_s)
    assert_equal("\004\004test", string.encode)
    assert_not_nil(string.asn1_type)
  end

  def test_octet_string_equals
    s1 = OctetString.new("test")
    s2 = "test"
    s3 = OctetString.new("test")
    assert_equal(s1, s2)
    assert(s1 == s2)
    assert_not_same(s1, s3)
    assert_equal(s1, s3)
  end

  def test_octet_string_to_oid
    s = OctetString.new("test")
    assert_equal(ObjectId.new([116, 101, 115, 116]), s.to_oid)
  end

  def test_object_id
    id = ObjectId.new([1,3,6,1])
    assert_equal("1.3.6.1", id.to_s)
    assert_equal("\006\003+\006\001", id.encode)
    assert_not_nil(id.asn1_type)
    assert_equal("1.3.6.1", id.to_varbind.name.to_s)

    assert_raise(ArgumentError) {
      ObjectId.new("xyzzy")
    }

    assert_equal("", ObjectId.new.to_s)
  end

  def test_object_id_to_s_with_mib
    mib = MIB.new
    mib.load_module("IF-MIB")
    id = ObjectId.new("1.3.6.1.2.1.2.2.1.2.1.1", mib)
    assert_equal("IF-MIB::ifDescr.1.1", id.to_s)
    assert_equal("1.3.6.1.2.1.2.2.1.2.1.1", id.to_str)
    assert_equal("[1.3.6.1.2.1.2.2.1.2.1.1]", id.inspect)
  end

  def test_object_id_create
    assert_equal("1.3.6.1", ObjectId.new("1.3.6.1").to_s)
    assert_equal("1.3.6.1", ObjectId.new([1,3,6,1]).to_s)
    assert_equal("1.3.6.1", ObjectId.new(ObjectId.new("1.3.6.1")).to_s)
  end

  def test_object_id_equals
    id1 = ObjectId.new("1.3.3.4")
    id2 = ObjectId.new([1,3,3,4])
    assert_not_same(id1, id2)
    assert(id1 == id2)
    assert_equal(id1, id2)
  end

  def test_object_id_comparable
    id1 = ObjectId.new("1.3.3.4")
    id2 = ObjectId.new("1.3.3.4.1")
    id3 = ObjectId.new("1.3.3.4.5")
    id4 = ObjectId.new("1.3.3.5")
    assert(id1 < id2)
    assert(id2 > id1)
    assert(id2 < id3)
    assert(id3 > id2)
    assert(id3 < id4)
    assert(id4 > id3)
  end

  def test_object_id_subtree
    id1 = ObjectId.new("1.3.3.4")
    id2 = ObjectId.new("1.3.3.4.1")
    id3 = ObjectId.new("1.3.3.4.5")
    id4 = ObjectId.new("1.3.3.5")
    assert(id2.subtree_of?(id1))
    assert(id3.subtree_of?(id1))
    assert(!id3.subtree_of?(id2))
    assert(!id1.subtree_of?(id2))
    assert(!id4.subtree_of?(id1))
    assert(!id4.subtree_of?(id3))
    assert(id1.subtree_of?("1.3.3.4"))
    assert(!id4.subtree_of?("1.3.3.4"))
  end

  def test_object_id_index
    id1 = ObjectId.new("1.3.3.4")
    id2 = ObjectId.new("1.3.3.4.1")
    id3 = ObjectId.new("1.3.3.4.1.2")
    assert_equal(ObjectId.new("1"), id2.index(id1))
    assert_equal(ObjectId.new("1.2"), id3.index(id1))
    assert_equal(ObjectId.new("1.2"), id3.index("1.3.3.4"))
    assert_raise(ArgumentError) { id1.index(id3) }
    assert_raise(ArgumentError) { id1.index(id1) }
  end

  def test_object_name_from_string
    id = ObjectName.new("1.3.4.5.6")
    assert_equal("1.3.4.5.6", id.to_s)
    assert_equal("\006\004+\004\005\006", id.encode)
  end

  def test_integer_create
    i = Integer.new(12345)
    assert_equal("12345", i.to_s)
    assert_equal(12345, i.to_i)
    assert_equal("\002\00209", i.encode)
    assert_not_nil(i.asn1_type)
  end

  def test_integer_create_from_string
    i = Integer.new("12345")
    assert_equal(12345, i.to_i)
  end

  def test_integer_decode
    i = Integer.decode("09")
    assert_equal(12345, i.to_i)
  end

  def test_integer_equal
    i1 = Integer.new(12345)
    i2 = Integer.new(12345)
    i3 = 12345.2
    i4 = 12345
    assert_not_same(i1, i2)
    assert_equal(i1, i2)
    assert_equal(i4, i1)
    assert_equal(i1, i4)
    assert_equal(i1, i3)
  end

  def test_integer_comparable
    i1 = Integer.new(12345)
    i2 = Integer.new(54321.0)
    assert(i1 < i2)
    assert(i2 > i1)
    assert(123 < i1)
    assert(123.0 < i1)
    assert(i2 > 54000)
  end

  def test_integer_to_oid
    assert_equal(ObjectId.new("123"), Integer.new(123).to_oid)
    assert_equal(ObjectId.new("0"), Integer.new(0).to_oid)

    i = Integer.new(-1)
    assert_raise(RangeError) { i.to_oid }
  end

  def test_ip_address_from_string
    ip = IpAddress.new("10.0.255.1")
    assert_equal("10.0.255.1", ip.to_s)
    assert_raise(InvalidIpAddress) { IpAddress.new("1233.2.3.4") }
    assert_raise(InvalidIpAddress) { IpAddress.new("1.2.3.-1") }
    assert_raise(InvalidIpAddress) { IpAddress.new("1.2.3") }
  end

  def test_ip_address_from_self
    ip1 = IpAddress.new("1.2.3.4")
    ip2 = IpAddress.new(ip1)
    assert_equal(ip1, ip2)
  end

  def test_ip_address_create
    ip = IpAddress.new("\001\002\003\004")
    assert_equal("1.2.3.4", ip.to_s)
    assert_equal("\001\002\003\004", ip.to_str)
    assert_equal("@\004\001\002\003\004", ip.encode)
    assert_not_nil(ip.asn1_type)
  end

  def test_ip_address_decode
    ip = IpAddress.decode("\001\002\003\004")
    assert_equal("1.2.3.4", ip.to_s)
  end

  def test_ip_address_decode_extra_octets
    ip = IpAddress.decode("\000\000\000\000\000\000\000\000")
    assert_equal("0.0.0.0.0.0.0.0", ip.to_s)

    ip = IpAddress.decode("\001\002\003")
    assert_equal("1.2.3", ip.to_s)

    ip = IpAddress.decode("\001\002\003\004\005")
    assert_equal("1.2.3.4.5", ip.to_s)
  end

  def test_ip_address_equals
    ip1 = IpAddress.new("1.2.3.4")
    ip2 = IpAddress.new("1.2.3.4")
    ip3 = IpAddress.new("10.2.3.4")
    assert(ip1 == ip2)
    assert(ip1.eql?(ip2))
    assert(!ip1.equal?(ip2))
    assert(ip1 != ip3)
    assert(ip1.hash == ip2.hash)
    assert(ip1.hash != ip3.hash)
    assert(!ip1.eql?(12))
  end

  def test_ip_address_to_oid
    ip = IpAddress.new("1.2.3.4")
    assert_equal(ObjectId.new("1.2.3.4"), ip.to_oid)
  end

  def test_counter32_create
    i = Counter32.new(12345)
    assert_equal("12345", i.to_s)
    assert_equal(12345, i.to_i)
    assert_equal("\x41\00209", i.encode)
    assert_not_nil(i.asn1_type)
  end

  def test_counter32_decode
    i = Counter32.decode("09")
    assert_equal(12345, i.to_i)
  end

  # Decode as a positive number even though high bit is set.
  # Not strict ASN.1, but implemented in some agents.
  def test_unsigned_decode
    i = Counter32.decode("\201\264\353\331")
    assert_equal(2176117721, i.to_i)

    i = TimeTicks.decode("\201\264\353\331")
    assert_equal(2176117721, i.to_i)
  end

  def test_counter64
    i = Counter64.new(18446744073709551615)
    assert_equal(18446744073709551615, i.to_i)
    assert_equal("18446744073709551615", i.to_s)
    assert_equal("F\t\000\377\377\377\377\377\377\377\377", i.encode)
    assert_equal(i, Counter64.decode("\000\377\377\377\377\377\377\377\377"))
    assert_not_nil(i.asn1_type)
  end

  def test_opaque
    q = Opaque.new("test")
    assert_equal("D\004test", q.encode)
    assert_equal("test", Opaque.decode("test"))
    assert_equal("test", q.to_s)
    assert_not_nil(q.asn1_type)
  end

  def test_exception_methods
    exception_types = [NoSuchObject, NoSuchInstance, EndOfMibView]
    exception_types.each do |type|
      assert(type.respond_to?(:decode))
      assert(type.respond_to?(:encode))
      assert_equal(type.asn1_type, type.to_s)
    end
  end

  def test_timeticks
    assert_equal("00:00:00.00", TimeTicks.new(0).to_s)
    assert_equal("00:00:00.01", TimeTicks.new(1).to_s)
    assert_equal("00:00:01.00", TimeTicks.new(100).to_s)
    assert_equal("00:01:00.00", TimeTicks.new(60 * 100).to_s)
    assert_equal("01:00:00.00", TimeTicks.new(60 * 60 * 100).to_s)
    assert_equal("23:59:59.99", TimeTicks.new(24 * 60 * 60 * 100 - 1).to_s)
    assert_equal("1 day, 00:00:00.00", TimeTicks.new(24 * 60 * 60 * 100).to_s)
    assert_equal("1 day, 23:59:59.99", TimeTicks.new(48 * 60 * 60 * 100 - 1).to_s)
    assert_equal("2 days, 00:00:00.00", TimeTicks.new(48 * 60 * 60 * 100).to_s)
    assert_equal("497 days, 02:27:52.95", TimeTicks.new(4294967295).to_s)
    assert_equal(4294967295, TimeTicks.new(4294967295).to_i)
    assert_raise(ArgumentError) {
      TimeTicks.new(4294967296)
    }
    assert_raise(ArgumentError) {
      TimeTicks.new(-1)
    }
  end
end
