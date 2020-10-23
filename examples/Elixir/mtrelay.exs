defmodule Mtrelay do
  @moduledoc """
  Generated by erl2ex (http://github.com/dazuma/erl2ex)
  From Erlang source: (Unknown source file)
  At: 2019-12-20 13:57:28

  """

  def step1(context) do
    {:ok, xmitter} = :erlzmq.socket(context, :pair)
    :ok = :erlzmq.connect(xmitter, 'inproc://step2')
    :io.format('Step 1 ready, signaling step 2~n')
    :ok = :erlzmq.send(xmitter, "READY")
    :ok = :erlzmq.close(xmitter)
  end


  def step2(context) do
    {:ok, receiver} = :erlzmq.socket(context, :pair)
    :ok = :erlzmq.bind(receiver, 'inproc://step2')
    :erlang.spawn(fn -> step1(context) end)
    {:ok, _} = :erlzmq.recv(receiver)
    :ok = :erlzmq.close(receiver)
    {:ok, xmitter} = :erlzmq.socket(context, :pair)
    :ok = :erlzmq.connect(xmitter, 'inproc://step3')
    :io.format('Step 2 ready, signaling step 3~n')
    :ok = :erlzmq.send(xmitter, "READY")
    :ok = :erlzmq.close(xmitter)
  end


  def main() do
    {:ok, context} = :erlzmq.context()
    {:ok, receiver} = :erlzmq.socket(context, :pair)
    :ok = :erlzmq.bind(receiver, 'inproc://step3')
    :erlang.spawn(fn -> step2(context) end)
    {:ok, _} = :erlzmq.recv(receiver)
    :erlzmq.close(receiver)
    :io.format('Test successful~n')
    :ok = :erlzmq.term(context)
  end

end

Mtrelay.main