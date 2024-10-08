defmodule Beacon.BeaconTest do
  use Beacon.DataCase, async: false

  describe "apply_mfa" do
    test "valid module" do
      assert Beacon.apply_mfa(String, :trim, [" beacon "]) == "beacon"
    end

    test "display context" do
      assert_raise Beacon.RuntimeError, ~r/beacon_test/, fn ->
        Beacon.apply_mfa(:invalid, :foo, [], context: %{source: "beacon_test"})
      end
    end

    test "invalid module" do
      assert_raise Beacon.RuntimeError, fn ->
        Beacon.apply_mfa(:invalid, :foo, [])
      end
    end
  end
end
