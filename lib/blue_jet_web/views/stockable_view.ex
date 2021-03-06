defmodule BlueJetWeb.StockableView do
  use BlueJetWeb, :view
  use JaSerializer.PhoenixView

  attributes [
    :status,
    :code,
    :name,
    :label,

    :print_name,
    :unit_of_measure,
    :variable_weight,

    :storage_type,
    :storage_size,
    :stackable,

    :specification,
    :storage_description,

    :caption,
    :description,
    :custom_data,

    :inserted_at,
    :updated_at
  ]

  has_one :avatar, serializer: BlueJetWeb.FileView, identifiers: :always
  has_many :file_collections, serializer: BlueJetWeb.FileCollectionView, identifiers: :when_included

  def type do
    "Stockable"
  end

  def avatar(%{ avatar_id: nil }, _), do: nil
  def avatar(%{ avatar_id: avatar_id, avatar: nil }, _), do: %{ id: avatar_id, type: "File" }
  def avatar(%{ avatar: avatar }, _), do: avatar
end
